import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:face_recognition/app/core/config/recognition_config.dart';
import 'package:face_recognition/app/core/helper/face_profile_store.dart';
import 'package:face_recognition/app/core/helper/face_recognition_util.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';
import 'face_overlay_painter.dart';

/// One angle the user is guided to present during enrollment.
class _PoseStep {
  final String label;
  final IconData icon;

  /// Returns true when the head pose (yaw = `headEulerAngleY`,
  /// pitch = `headEulerAngleX`, both degrees) satisfies this step.
  final bool Function(double yaw, double pitch) matches;

  const _PoseStep(this.label, this.icon, this.matches);
}

/// Guided, auto-capturing multi-angle enrollment. Walks the user through a few
/// head poses (front, sides, up/down) and captures one face embedding per pose,
/// storing them all as templates so live recognition is robust to pose,
/// lighting and expression changes.
class FaceEnrollmentView extends StatefulWidget {
  const FaceEnrollmentView({super.key});

  @override
  State<FaceEnrollmentView> createState() => _FaceEnrollmentViewState();
}

class _FaceEnrollmentViewState extends State<FaceEnrollmentView> {
  // Pose thresholds for enrollment (degrees). Kept modest so they are easy to
  // hit while still producing meaningfully different angles.
  static const double _yawTarget = 15;
  static const double _pitchTarget = 12;

  // The face must satisfy a pose for this many consecutive frames before it is
  // captured, to avoid grabbing a blurry in-between frame.
  static const int _requiredStableFrames = 5;

  static final List<_PoseStep> _allSteps = [
    _PoseStep('Look straight ahead', Icons.face,
        (yaw, pitch) => yaw.abs() < 8 && pitch.abs() < 12),
    // Front camera is mirrored, so a head turn to the user's right yields a
    // negative yaw (and vice-versa). Map the prompts to the user's real
    // direction rather than the raw sign.
    _PoseStep('Turn your head right', Icons.arrow_forward,
        (yaw, pitch) => yaw <= -_yawTarget),
    _PoseStep('Turn your head left', Icons.arrow_back,
        (yaw, pitch) => yaw >= _yawTarget),
    _PoseStep('Tilt your head up', Icons.arrow_upward,
        (yaw, pitch) => pitch >= _pitchTarget),
    _PoseStep('Tilt your head down', Icons.arrow_downward,
        (yaw, pitch) => pitch <= -_pitchTarget),
  ];

  CameraController? _controller;
  CameraDescription? _camera;
  Interpreter? _interpreter;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      enableTracking: true,
    ),
  );

  late final List<_PoseStep> _steps;
  late final double _minFaceWidthFraction;
  late final double _dupThreshold;

  final List<List<double>> _collected = [];
  // Face crop saved from the first (front) pose, used as the profile photo.
  img.Image? _photoImage;
  int _stepIndex = 0;
  int _stableFrames = 0;
  bool _flash = false;
  bool _saving = false;

  bool _isBusy = false;
  bool _done = false;
  String _status = 'Initializing camera...';

  Rect? _faceRect;
  Size _imageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  int _rotationDegrees = 0;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    final samples = cfgEnrollSamples.$.clamp(1, _allSteps.length);
    _steps = _allSteps.take(samples).toList();
    _minFaceWidthFraction = cfgMinFaceWidthFraction.$;
    _dupThreshold = cfgMatchThreshold.$;
    _init();
  }

  Future<void> _init() async {
    try {
      _interpreter = await Interpreter.fromAsset('asset/mobilefacenet.tflite');

      final cameras = await availableCameras();
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        _camera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;

      setState(() => _status = _steps.first.label);
      await controller.startImageStream(_processFrame);
    } catch (e) {
      if (mounted) setState(() => _status = 'Camera error: $e');
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _done || _saving || !mounted) return;
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        _stableFrames = 0;
        if (mounted) {
          setState(() {
            _faceRect = null;
            _status = 'Position your face in the frame';
          });
        }
        return;
      }

      final face = faces.first;
      final frameSize = inputImage.metadata!.size;
      if (mounted) {
        setState(() {
          _faceRect = face.boundingBox;
          _imageSize = frameSize;
          _rotation = inputImage.metadata!.rotation;
        });
      }

      // Quality gate: face must be large enough (close enough to the camera).
      final faceWidthFraction = face.boundingBox.width / frameSize.width;
      if (faceWidthFraction < _minFaceWidthFraction) {
        _stableFrames = 0;
        if (mounted) setState(() => _status = 'Move a bit closer');
        return;
      }

      final step = _steps[_stepIndex];
      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;

      if (step.matches(yaw, pitch)) {
        _stableFrames++;
        if (_stableFrames >= _requiredStableFrames) {
          await _captureCurrentStep(image, face.boundingBox);
        } else if (mounted) {
          setState(() => _status = 'Hold still — capturing ${step.label}');
        }
      } else {
        _stableFrames = 0;
        if (mounted) setState(() => _status = step.label);
      }
    } catch (_) {
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _captureCurrentStep(CameraImage image, Rect box) async {
    final interpreter = _interpreter;
    if (interpreter == null) return;

    img.Image frame = FaceRecognitionUtil.nv21ToImage(image);
    if (_rotationDegrees != 0) {
      frame = img.copyRotate(frame, angle: _rotationDegrees);
    }
    final img.Image faceImg = FaceRecognitionUtil.cropFace(frame, box);
    final embedding = FaceRecognitionUtil.embed(interpreter, faceImg);

    _collected.add(embedding);
    // Save a roomy crop of the first (front) pose as the profile photo.
    _photoImage ??= _photoCrop(frame, box);
    _stableFrames = 0;

    if (mounted) {
      setState(() => _flash = true);
    }
    // Brief visual confirmation between captures.
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() => _flash = false);

    if (_stepIndex + 1 >= _steps.length) {
      await _finish();
    } else {
      _stepIndex++;
      if (mounted) setState(() => _status = _steps[_stepIndex].label);
    }
  }

  Future<void> _finish() async {
    _done = true;
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;

    // If this face is already enrolled, update that person instead of creating
    // a duplicate.
    final existing =
        FaceProfileStore.findDuplicate(_collected, _dupThreshold);
    if (existing != null) {
      setState(() {
        _saving = true;
        _status = 'Already enrolled — updating ${existing.name}...';
      });
      String? photoPath;
      final photo = _photoImage;
      if (photo != null) {
        try {
          photoPath = await FaceProfileStore.savePhoto(photo, existing.id);
        } catch (_) {}
      }
      final updated = await FaceProfileStore.mergeInto(
        existing,
        newTemplates: _collected,
        photoPath: photoPath,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _status = 'Updated ${updated.name}';
      });
      _showResultDialog(
        title: 'Enrollment Updated',
        message: '${updated.name} is already enrolled — added '
            '${_collected.length} new angle'
            '${_collected.length == 1 ? '' : 's'} '
            '(${updated.templates.length} total).',
      );
      return;
    }

    setState(() => _status = 'Captured — name this person');
    final name = await _promptName();
    if (name == null) {
      // Cancelled: discard this enrollment.
      if (mounted) Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _saving = true;
      _status = 'Saving...';
    });

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String photoPath = '';
    final photo = _photoImage;
    if (photo != null) {
      try {
        photoPath = await FaceProfileStore.savePhoto(photo, id);
      } catch (_) {}
    }
    await FaceProfileStore.add(FaceProfile(
      id: id,
      name: name,
      photoPath: photoPath,
      templates: _collected,
    ));

    if (!mounted) return;
    setState(() {
      _saving = false;
      _status = 'Enrollment complete';
    });
    _showResultDialog(
      title: 'Face Enrolled',
      message: '$name enrolled with ${_collected.length} angle'
          '${_collected.length == 1 ? '' : 's'}.',
    );
  }

  void _showResultDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.verified_user, color: Colors.green, size: 40),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Asks the user to name the enrolled person. Returns the trimmed name, or
  /// null if cancelled. Empty input falls back to "Person".
  Future<String?> _promptName() {
    final textController = TextEditingController();
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Name this person'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(
            v.trim().isEmpty ? 'Person' : v.trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(
              textController.text.trim().isEmpty
                  ? 'Person'
                  : textController.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// A roomy (margin-padded) square crop around [box], resized for use as a
  /// profile thumbnail.
  img.Image _photoCrop(img.Image frame, Rect box) {
    const double scale = 1.5;
    final double cx = box.left + box.width / 2;
    final double cy = box.top + box.height / 2;
    final double side = (box.width > box.height ? box.width : box.height) * scale;
    final int x = (cx - side / 2).round().clamp(0, frame.width - 1);
    final int y = (cy - side / 2).round().clamp(0, frame.height - 1);
    final int w = side.round().clamp(1, frame.width - x);
    final int h = side.round().clamp(1, frame.height - y);
    final crop = img.copyCrop(frame, x: x, y: y, width: w, height: h);
    return img.copyResize(crop, width: 240, height: 240);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _camera;
    final controller = _controller;
    if (camera == null || controller == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      var rotationCompensation =
          _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation =
            (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;
    _rotationDegrees = rotation.rawValue;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final bool ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'Enroll Face',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (ready)
            Center(
              child: CameraPreview(
                controller,
                child: CustomPaint(
                  painter: _faceRect == null
                      ? null
                      : FaceBoxPainter(
                          rect: _faceRect!,
                          imageSize: _imageSize,
                          rotation: _rotation,
                          lensDirection: _camera!.lensDirection,
                          color: _flash ? Colors.green : AppColors.primaryColor,
                        ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          if (_flash)
            const Positioned.fill(
              child: ColoredBox(color: Color(0x3300FF66)),
            ),

          // Progress dots: one per required sample.
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                final captured = i < _collected.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: captured ? Colors.green : Colors.white24,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                );
              }),
            ),
          ),

          // Current instruction.
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_done && _stepIndex < _steps.length)
                    Icon(_steps[_stepIndex].icon,
                        color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_collected.length}/${_steps.length}  •  $_status',
                      style: TextStyle(
                        color: _done ? Colors.green : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
