import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:face_recognition/app/core/config/recognition_config.dart';
import 'package:face_recognition/app/core/helper/face_profile_store.dart';
import 'package:face_recognition/app/core/helper/face_recognition_util.dart';
import 'package:face_recognition/app/core/helper/spoof_detector.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';
import 'face_overlay_painter.dart';

/// Live camera screen that streams frames, marks any detected face with a
/// rectangle and matches it against the enrolled face templates. Before a
/// match is accepted the user must pass the configured liveness / anti-spoofing
/// challenges (blink / head turn / smile), which a printed photo or replayed
/// video cannot satisfy on demand. When a live match is found it shows a
/// message and stops the camera stream.
class LiveRecognitionView extends StatefulWidget {
  const LiveRecognitionView({super.key});

  @override
  State<LiveRecognitionView> createState() => _LiveRecognitionViewState();
}

class _LiveRecognitionViewState extends State<LiveRecognitionView> {
  CameraController? _controller;
  CameraDescription? _camera;
  Interpreter? _interpreter;

  // Classification (eye-open / smiling probabilities) and head pose are
  // required for the liveness challenges, so they are enabled here.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      enableTracking: true,
    ),
  );

  late final List<FaceProfile> _profiles;
  late final double _minFaceWidthFraction;

  // ---- Configurable settings (snapshotted on entry) ----------------------
  late final double _matchThreshold;
  late final bool _livenessEnabled;
  late final bool _randomizeLiveness;
  // The config toggles define the *pool* of allowed challenges; the active
  // challenge(s) are chosen from this pool by [_pickChallenges].
  late final bool _poolBlink;
  late final bool _poolHeadTurn;
  late final bool _poolSmile;
  late final double _eyeClosedThreshold;
  late final double _eyeOpenThreshold;
  late final double _headTurnThreshold;
  late final double _smileThreshold;
  late final int _livenessTimeoutSec;
  late final bool _passiveSpoofEnabled;
  late final double _spoofLiveThreshold;

  // Active challenges for the current attempt (re-picked on each retry).
  bool _requireBlink = false;
  bool _requireHeadTurn = false;
  bool _requireSmile = false;

  // Passive texture/CNN anti-spoofing. Null when disabled or unloadable.
  SpoofDetector? _spoofDetector;
  bool _spoofModelMissing = false;

  // ---- Liveness state ----------------------------------------------------
  bool _livenessPassed = false;
  bool _livenessFailed = false;
  bool _blinkDone = false;
  bool _headTurnDone = false;
  bool _smileDone = false;
  // Blink is open -> closed -> open; these track the sub-sequence.
  bool _eyeOpenSeen = false;
  bool _eyeCloseSeen = false;
  DateTime? _livenessStart;

  bool _isBusy = false;
  bool _matched = false;
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
    _profiles = FaceProfileStore.all;

    // Snapshot the user-tweakable config once so mid-session changes don't
    // alter behaviour partway through a scan.
    _matchThreshold = cfgMatchThreshold.$;
    _minFaceWidthFraction = cfgMinFaceWidthFraction.$;
    _livenessEnabled = cfgLivenessEnabled.$;
    _randomizeLiveness = cfgRandomizeLiveness.$;
    _poolBlink = cfgRequireBlink.$;
    _poolHeadTurn = cfgRequireHeadTurn.$;
    _poolSmile = cfgRequireSmile.$;
    _eyeClosedThreshold = cfgEyeClosedThreshold.$;
    _eyeOpenThreshold = cfgEyeOpenThreshold.$;
    _headTurnThreshold = cfgHeadTurnThreshold.$;
    _smileThreshold = cfgSmileThreshold.$;
    _livenessTimeoutSec = cfgLivenessTimeoutSec.$;
    _passiveSpoofEnabled = cfgPassiveSpoofEnabled.$;
    _spoofLiveThreshold = cfgSpoofLiveThreshold.$;

    _pickChallenges();

    // With liveness off, or with no challenge selected, there is nothing to
    // prove — treat liveness as already passed.
    _livenessPassed = !_livenessEnabled ||
        (!_requireBlink && !_requireHeadTurn && !_requireSmile);

    _init();
  }

  /// Selects the active liveness challenge(s) for this attempt. With
  /// randomization on and more than one challenge in the pool, exactly one is
  /// chosen at random so a pre-recorded attack can't anticipate the prompt;
  /// otherwise every pooled challenge is required.
  void _pickChallenges() {
    bool blink = _poolBlink;
    bool head = _poolHeadTurn;
    bool smile = _poolSmile;

    if (_livenessEnabled && _randomizeLiveness) {
      final pool = <String>[
        if (blink) 'blink',
        if (head) 'head',
        if (smile) 'smile',
      ];
      if (pool.length > 1) {
        final pick = pool[Random().nextInt(pool.length)];
        blink = pick == 'blink';
        head = pick == 'head';
        smile = pick == 'smile';
      }
    }

    _requireBlink = blink;
    _requireHeadTurn = head;
    _requireSmile = smile;
  }

  Future<void> _init() async {
    if (_profiles.isEmpty) {
      setState(() => _status = 'No one enrolled. Enroll a face first.');
      return;
    }
    try {
      _interpreter =
          await Interpreter.fromAsset('asset/mobilefacenet.tflite');

      // Load the passive texture/CNN anti-spoof model if enabled. If the model
      // file is absent it fails open (gate skipped) with a visible note.
      if (_passiveSpoofEnabled) {
        final detector = SpoofDetector();
        await detector.load();
        if (detector.isAvailable) {
          _spoofDetector = detector;
        } else {
          _spoofModelMissing = true;
        }
      }

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

      _livenessStart = DateTime.now();
      setState(() => _status = _livenessPassed ? 'Scanning...' : _livenessHint());
      await controller.startImageStream(_processFrame);
    } catch (e) {
      if (mounted) setState(() => _status = 'Camera error: $e');
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _matched || _livenessFailed || !mounted) return;
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _faceRect = null;
            _status = _livenessPassed ? 'Scanning...' : _livenessHint();
          });
        }
        return;
      }

      final face = faces.first;
      if (mounted) {
        setState(() {
          _faceRect = face.boundingBox;
          _imageSize = inputImage.metadata!.size;
          _rotation = inputImage.metadata!.rotation;
        });
      }

      // Liveness must pass before any identity match is accepted.
      if (!_livenessPassed) {
        _updateLiveness(face);
        if (!_livenessPassed) return;
      }

      await _matchFace(image, face.boundingBox);
    } catch (_) {

    } finally {
      _isBusy = false;
    }
  }

  // ---- Liveness / anti-spoofing ------------------------------------------

  /// Advances the liveness state machine from a single detected [face],
  /// updating the on-screen prompt and enforcing the timeout.
  void _updateLiveness(Face face) {
    // Enforce the overall timeout for completing all challenges.
    final start = _livenessStart;
    if (start != null &&
        DateTime.now().difference(start).inSeconds >= _livenessTimeoutSec) {
      _onLivenessFailed();
      return;
    }

    // Blink: detect an open -> closed -> open eye sequence.
    if (_requireBlink && !_blinkDone) {
      final left = face.leftEyeOpenProbability;
      final right = face.rightEyeOpenProbability;
      if (left != null && right != null) {
        final openProb = (left + right) / 2;
        if (openProb >= _eyeOpenThreshold) {
          if (_eyeCloseSeen) {
            _blinkDone = true;
          } else {
            _eyeOpenSeen = true;
          }
        } else if (openProb <= _eyeClosedThreshold && _eyeOpenSeen) {
          _eyeCloseSeen = true;
        }
      }
    }

    // Head turn: yaw beyond the configured angle in either direction.
    if (_requireHeadTurn && !_headTurnDone) {
      final yaw = face.headEulerAngleY;
      if (yaw != null && yaw.abs() >= _headTurnThreshold) {
        _headTurnDone = true;
      }
    }

    // Smile.
    if (_requireSmile && !_smileDone) {
      final smile = face.smilingProbability;
      if (smile != null && smile >= _smileThreshold) {
        _smileDone = true;
      }
    }

    final passed = (!_requireBlink || _blinkDone) &&
        (!_requireHeadTurn || _headTurnDone) &&
        (!_requireSmile || _smileDone);

    if (mounted) {
      setState(() {
        _livenessPassed = passed;
        _status = passed ? 'Liveness OK — hold still...' : _livenessHint();
      });
    } else {
      _livenessPassed = passed;
    }
  }

  /// Builds the prompt for the next incomplete liveness challenge.
  String _livenessHint() {
    if (_requireBlink && !_blinkDone) return 'Blink your eyes';
    if (_requireHeadTurn && !_headTurnDone) return 'Slowly turn your head';
    if (_requireSmile && !_smileDone) return 'Please smile';
    return 'Hold still...';
  }

  Future<void> _onLivenessFailed() async {
    _livenessFailed = true;
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _status = 'Liveness check failed');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.gpp_bad, color: Colors.red, size: 40),
        title: const Text('Liveness Failed'),
        content: const Text(
          'Could not confirm a live person in time. Please try again and '
          'follow the on-screen prompts.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restartLiveness();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Resets the liveness state machine and resumes the camera stream.
  Future<void> _restartLiveness() async {
    _livenessFailed = false;
    _blinkDone = false;
    _headTurnDone = false;
    _smileDone = false;
    _eyeOpenSeen = false;
    _eyeCloseSeen = false;
    // Re-randomize the challenge so each retry asks for a fresh action.
    _pickChallenges();
    _livenessPassed = !_livenessEnabled ||
        (!_requireBlink && !_requireHeadTurn && !_requireSmile);
    _livenessStart = DateTime.now();
    if (mounted) {
      setState(() => _status = _livenessPassed ? 'Scanning...' : _livenessHint());
    }
    try {
      if (_controller != null && !_controller!.value.isStreamingImages) {
        await _controller!.startImageStream(_processFrame);
      }
    } catch (_) {}
  }

  Future<void> _matchFace(CameraImage image, Rect box) async {
    final interpreter = _interpreter;
    if (interpreter == null) return;

    // Quality gate: ignore distant/tiny faces to avoid low-confidence matches.
    if (box.width / _imageSize.width < _minFaceWidthFraction) {
      if (mounted) setState(() => _status = 'Move a bit closer');
      return;
    }

    // Convert the frame to an upright RGB image matching ML Kit's coordinates.
    img.Image frame = FaceRecognitionUtil.nv21ToImage(image);
    if (_rotationDegrees != 0) {
      frame = img.copyRotate(frame, angle: _rotationDegrees);
    }

    // Passive anti-spoofing gate: reject the frame if the texture model judges
    // it a spoof. A null score (model missing/errored) skips the gate.
    final detector = _spoofDetector;
    if (detector != null) {
      final live = detector.liveProbability(frame, box);
      if (live != null && live < _spoofLiveThreshold) {
        if (mounted) {
          setState(() => _status =
              'Spoof suspected (${(live * 100).toStringAsFixed(0)}% live)');
        }
        return;
      }
    }

    final img.Image faceImg = FaceRecognitionUtil.cropFace(frame, box);
    final embedding = FaceRecognitionUtil.embed(interpreter, faceImg);

    // 1:N identification — find the enrolled person whose closest angle is the
    // best match for this face.
    FaceProfile? best;
    double bestSim = -1;
    for (final profile in _profiles) {
      final s = FaceRecognitionUtil.bestSimilarity(embedding, profile.templates);
      if (s > bestSim) {
        bestSim = s;
        best = profile;
      }
    }

    if (best != null && bestSim >= _matchThreshold) {
      await _onMatched(best, bestSim);
    } else if (mounted) {
      setState(() => _status =
          'Unknown (best ${(bestSim * 100).toStringAsFixed(1)}%)');
    }
  }

  Future<void> _onMatched(FaceProfile profile, double similarity) async {
    _matched = true;
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _status =
        '${profile.name} (${(similarity * 100).toStringAsFixed(1)}%)');

    final hasPhoto =
        profile.photoPath.isNotEmpty && File(profile.photoPath).existsSync();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Identified'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPhoto)
              CircleAvatar(
                radius: 44,
                backgroundImage: FileImage(File(profile.photoPath)),
              )
            else
              const CircleAvatar(
                radius: 44,
                child: Icon(Icons.person, size: 44),
              ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Verified with ${(similarity * 100).toStringAsFixed(1)}% '
              'similarity.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ---- Frame conversion --------------------------------------------------

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
    _spoofDetector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final bool ready =
        controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'Live Recognition',
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
                          color: _matched
                              ? Colors.green
                              : AppColors.primaryColor,
                        ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          if (_spoofModelMissing)
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Anti-spoof model not found — passive check skipped. '
                  'Add asset/antispoof.tflite to enable it.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _matched ? Colors.green : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
