import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:face_recognition/app/core/helper/app_helper.dart';
import 'package:face_recognition/app/core/helper/print_log.dart';
import 'package:face_recognition/app/core/helper/shared_value_helper.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../views/face_preview_dialog.dart';
import '../views/live_recognition_view.dart';


class HomeController extends GetxController {
  final isLoading = false.obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString imagePath = ''.obs;

  // Detected face details for the captured image.
  Rect? faceRect;
  int imageWidth = 0;
  int imageHeight = 0;

  @override
  void onInit() {
    super.onInit();
    faceEmbedding.load();
  }


  final faceDetector = FaceDetector(options: FaceDetectorOptions(
    performanceMode: FaceDetectorMode.fast,
  ));


  void pickImage () async {
    var image = await imagePicker.pickImage(
        source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null) {
      imagePath.value = image.path;
      final hasFace = await detectFace();
      if (hasFace) {
        _showFacePreviewDialog();
      } else {
        Get.snackbar(
          'No face found',
          'Could not detect a face. Please retake the image.',
        );
      }
    }
  }

  /// Opens the live recognition screen, warning the user if no reference
  /// face has been enrolled yet.
  void startLiveRecognition() {
    if (faceEmbedding.$.isEmpty) {
      Get.snackbar(
        'No face enrolled',
        'Please capture and confirm a face first before starting '
            'live recognition.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    Get.to(() => const LiveRecognitionView());
  }

  /// Detects the face in the captured image and stores its bounding box
  /// along with the image dimensions. Returns true if a face was found.
  Future<bool> detectFace() async {
    final inputImage = InputImage.fromFilePath(imagePath.value);

    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print("No face found");
      faceRect = null;
      return false;
    }

    faceRect = faces.first.boundingBox;

    final bytes = File(imagePath.value).readAsBytesSync();
    final img.Image original = img.decodeImage(bytes)!;
    imageWidth = original.width;
    imageHeight = original.height;

    return true;
  }

  void _showFacePreviewDialog() {
    Get.dialog(
      FacePreviewDialog(
        imagePath: imagePath.value,
        faceRect: faceRect!,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        onRetake: () {
          Get.back();
          pickImage();
        },
        onConfirm: () {
          Get.back();
          extractEmbedding();
        },
      ),
      barrierDismissible: false,
    );
  }

  /// Crops the confirmed face and computes its embedding.
  Future<void> extractEmbedding() async {
    if (faceRect == null) return;

    AppHelper().showLoader();
    try {
      final bytes = File(imagePath.value).readAsBytesSync();
      img.Image original = img.decodeImage(bytes)!;

      final rect = faceRect!;

      // Clamp the bounding box so the crop stays within the image bounds.
      final int x = rect.left.toInt().clamp(0, original.width - 1);
      final int y = rect.top.toInt().clamp(0, original.height - 1);
      final int width = rect.width.toInt().clamp(1, original.width - x);
      final int height = rect.height.toInt().clamp(1, original.height - y);

      img.Image croppedFace = img.copyCrop(
        original,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      img.Image resized = img.copyResize(
        croppedFace,
        width: 112,
        height: 112,
      );

      Float32List input = imageToByteListFloat32(resized);

      List<double> embedding = await getEmbedding(input);

      printLog(embedding);

      AppHelper().hideLoader();
      Get.snackbar(
        'Face saved',
        'Face embedding saved successfully. You can now use live recognition.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      AppHelper().hideLoader();
      Get.snackbar(
        'Error',
        'Failed to save face embedding: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(12),
      );
    }
  }


  Float32List imageToByteListFloat32(img.Image image) {
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

  Future<List<double>> getEmbedding(Float32List input) async {
    var inputTensor = input.reshape([1, 112, 112, 3]);

    var output = List.generate(
      1, (_) => List.filled(192, 0.0),
    );

    Interpreter interpreter = await Interpreter.fromAsset('asset/mobilefacenet.tflite');

    interpreter.run(inputTensor, output);

    List<double> embedding =
    output[0].map((e) => e.toDouble()).toList();


    interpreter.close();
    faceEmbedding.$ = embedding;
    faceEmbedding.save();
    return embedding;
  }

  double compareEmbeddings(List<double> emb1, List<double> emb2,) {
    double sum = 0;

    for (int i = 0; i < emb1.length; i++) {
      sum += pow(emb1[i] - emb2[i], 2);
    }

    return sqrt(sum);
  }
}


