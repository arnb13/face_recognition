import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:face_recognition/app/core/style/app_colors.dart';
import '../../../core/helper/shared_value_helper.dart';

/// Live camera screen that streams frames, marks any detected face with a
/// rectangle and matches it against the enrolled [faceEmbedding]. When a match
/// is found it shows a message and stops the camera stream.
class LiveRecognitionView extends StatefulWidget {
  const LiveRecognitionView({super.key});

  @override
  State<LiveRecognitionView> createState() => _LiveRecognitionViewState();
}

class _LiveRecognitionViewState extends State<LiveRecognitionView> {
  static const double _matchThreshold = 0.8;

  CameraController? _controller;
  CameraDescription? _camera;
  Interpreter? _interpreter;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  late final List<double> _savedEmbedding;

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
    _savedEmbedding = List<double>.from(faceEmbedding.$);
    _init();
  }

  Future<void> _init() async {
    if (_savedEmbedding.isEmpty) {
      setState(() => _status = 'No enrolled face. Capture a face first.');
      return;
    }
    try {
      _interpreter =
          await Interpreter.fromAsset('asset/mobilefacenet.tflite');

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

      setState(() => _status = 'Scanning...');
      await controller.startImageStream(_processFrame);
    } catch (e) {
      if (mounted) setState(() => _status = 'Camera error: $e');
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _matched || !mounted) return;
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _faceRect = null;
            _status = 'Scanning...';
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

      await _matchFace(image, face.boundingBox);
    } catch (_) {

    } finally {
      _isBusy = false;
    }
  }

  Future<void> _matchFace(CameraImage image, Rect box) async {
    final interpreter = _interpreter;
    if (interpreter == null) return;

    // Convert the frame to an upright RGB image matching ML Kit's coordinates.
    img.Image frame = _nv21ToImage(image);
    if (_rotationDegrees != 0) {
      frame = img.copyRotate(frame, angle: _rotationDegrees);
    }

    final int x = box.left.toInt().clamp(0, frame.width - 1);
    final int y = box.top.toInt().clamp(0, frame.height - 1);
    final int w = box.width.toInt().clamp(1, frame.width - x);
    final int h = box.height.toInt().clamp(1, frame.height - y);

    final img.Image crop =
        img.copyCrop(frame, x: x, y: y, width: w, height: h);
    final img.Image resized = img.copyResize(crop, width: 112, height: 112);

    final embedding = _embed(interpreter, resized);
    final similarity = _cosineSimilarity(embedding, _savedEmbedding);

    if (similarity >= _matchThreshold) {
      await _onMatched(similarity);
    } else if (mounted) {
      setState(() => _status =
          'Match: ${(similarity * 100).toStringAsFixed(1)}%');
    }
  }

  Future<void> _onMatched(double similarity) async {
    _matched = true;
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _status =
        'Face matched (${(similarity * 100).toStringAsFixed(1)}%)');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.verified, color: Colors.green, size: 40),
        title: const Text('Face Matched'),
        content: Text(
          'Identity verified with '
          '${(similarity * 100).toStringAsFixed(1)}% similarity.',
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

  // ---- Embedding helpers -------------------------------------------------

  List<double> _embed(Interpreter interpreter, img.Image image) {
    final input = _imageToByteListFloat32(image).reshape([1, 112, 112, 3]);
    final output = List.generate(1, (_) => List.filled(192, 0.0));
    interpreter.run(input, output);
    return output[0].map((e) => e.toDouble()).toList();
  }

  Float32List _imageToByteListFloat32(img.Image image) {
    final buffer = Float32List(1 * 112 * 112 * 3);
    int index = 0;
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = (pixel.r - 127.5) / 127.5;
        buffer[index++] = (pixel.g - 127.5) / 127.5;
        buffer[index++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return buffer;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return -1;
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return -1;
    return dot / (sqrt(na) * sqrt(nb));
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

  /// Decodes a single-plane NV21 [CameraImage] to an RGB [img.Image].
  img.Image _nv21ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Uint8List bytes = image.planes.first.bytes;
    final int yStride = image.planes.first.bytesPerRow;
    final int uvStart = yStride * height;

    final out = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final int yRow = y * yStride;
      final int uvRow = uvStart + (y >> 1) * yStride;
      for (int x = 0; x < width; x++) {
        final int yVal = bytes[yRow + x] & 0xff;
        final int uvIndex = uvRow + (x & ~1);
        final int v = (bytes[uvIndex] & 0xff) - 128;
        final int u = (bytes[uvIndex + 1] & 0xff) - 128;

        final int r = (yVal + 1.370705 * v).round().clamp(0, 255);
        final int g =
            (yVal - 0.337633 * u - 0.698001 * v).round().clamp(0, 255);
        final int b = (yVal + 1.732446 * u).round().clamp(0, 255);

        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
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
                      : _FacePainter(
                          rect: _faceRect!,
                          imageSize: _imageSize,
                          rotation: _rotation,
                          lensDirection: _camera!.lensDirection,
                          matched: _matched,
                        ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
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

/// Draws the detected face rectangle, mapping ML Kit image coordinates onto
/// the camera preview (accounting for rotation and front-camera mirroring).
class _FacePainter extends CustomPainter {
  final Rect rect;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;
  final bool matched;

  _FacePainter({
    required this.rect,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    required this.matched,
  });

  double _translateX(double x, Size canvas) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * canvas.width / imageSize.height;
      case InputImageRotation.rotation270deg:
        return canvas.width - x * canvas.width / imageSize.height;
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        if (lensDirection == CameraLensDirection.back) {
          return x * canvas.width / imageSize.width;
        }
        return canvas.width - x * canvas.width / imageSize.width;
    }
  }

  double _translateY(double y, Size canvas) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * canvas.height / imageSize.width;
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return y * canvas.height / imageSize.height;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == Size.zero) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = matched ? Colors.green : AppColors.primaryColor;

    final left = _translateX(rect.left, size);
    final right = _translateX(rect.right, size);
    final top = _translateY(rect.top, size);
    final bottom = _translateY(rect.bottom, size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(min(left, right), top, max(left, right), bottom),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) {
    return oldDelegate.rect != rect || oldDelegate.matched != matched;
  }
}
