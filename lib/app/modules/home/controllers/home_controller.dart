import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:face_recognition/app/core/config/recognition_config.dart';
import 'package:face_recognition/app/core/helper/app_helper.dart';
import 'package:face_recognition/app/core/helper/face_profile_store.dart';
import 'package:face_recognition/app/core/helper/print_log.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../views/face_enrollment_view.dart';
import '../views/face_preview_dialog.dart';
import '../views/live_recognition_view.dart';


class HomeController extends GetxController {
  final isLoading = false.obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString imagePath = ''.obs;

  /// Enrolled people, reflected on the home screen.
  final profiles = <FaceProfile>[].obs;

  // Detected face details for the captured image.
  Rect? faceRect;
  int imageWidth = 0;
  int imageHeight = 0;

  @override
  void onInit() {
    super.onInit();
    _loadState();
  }

  Future<void> _loadState() async {
    await Future.wait([FaceProfileStore.load(), loadRecognitionConfig()]);
    _refreshProfiles();
  }

  void _refreshProfiles() => profiles.assignAll(FaceProfileStore.all);

  /// Opens the guided multi-angle enrollment flow and refreshes the list when
  /// a new person is enrolled.
  void startEnrollment() async {
    final result = await Get.to(() => const FaceEnrollmentView());
    if (result == true) {
      _refreshProfiles();
    }
  }

  /// Removes a single enrolled person (and their photo).
  void removeProfile(FaceProfile profile) async {
    await FaceProfileStore.removeById(profile.id);
    _refreshProfiles();
    Get.snackbar(
      'Removed',
      '${profile.name} has been removed.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  /// Removes every enrolled person.
  void clearAll() async {
    await FaceProfileStore.clear();
    _refreshProfiles();
    Get.snackbar(
      'Cleared',
      'All enrolled people have been removed.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }


  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );


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
    if (FaceProfileStore.isEmpty) {
      Get.snackbar(
        'No face enrolled',
        'Please enroll a face first before starting live recognition.',
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
  /// Detection failures (e.g. a transient ML Kit error) are caught so they
  /// surface as a retry prompt instead of crashing the app.
  Future<bool> detectFace() async {
    // ML Kit can throw a transient NullPointerException on its first
    // invocation (more common on release builds); recreate the detector and
    // retry once before giving up.
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final inputImage = InputImage.fromFilePath(imagePath.value);
        final faces = await faceDetector.processImage(inputImage);

        if (faces.isEmpty) {
          printLog("No face found");
          faceRect = null;
          return false;
        }

        faceRect = faces.first.boundingBox;

        final bytes = File(imagePath.value).readAsBytesSync();
        final img.Image original = img.decodeImage(bytes)!;
        imageWidth = original.width;
        imageHeight = original.height;

        return true;
      } catch (e) {
        printLog('Face detection attempt $attempt failed: $e');
        faceRect = null;
        if (attempt == 1) {
          try {
            await faceDetector.close();
          } catch (_) {}
          faceDetector = FaceDetector(
            options: FaceDetectorOptions(
              performanceMode: FaceDetectorMode.fast,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    return false;
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

  /// Crops the confirmed face, computes its embedding, asks for a name and
  /// saves it as a new enrolled person (single-angle "quick enroll").
  Future<void> extractEmbedding() async {
    if (faceRect == null) return;

    AppHelper().showLoader();
    List<double> embedding;
    img.Image photo;
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

      img.Image resized = img.copyResize(croppedFace, width: 112, height: 112);
      Float32List input = imageToByteListFloat32(resized);
      embedding = await getEmbedding(input);
      photo = img.copyResize(croppedFace, width: 240, height: 240);
      printLog(embedding);
    } catch (e) {
      AppHelper().hideLoader();
      Get.snackbar(
        'Error',
        'Failed to read face: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    AppHelper().hideLoader();

    // If this face is already enrolled, update that person instead of adding a
    // duplicate.
    final existing =
        FaceProfileStore.findDuplicate([embedding], cfgMatchThreshold.$);
    if (existing != null) {
      AppHelper().showLoader();
      try {
        String? photoPath;
        try {
          photoPath = await FaceProfileStore.savePhoto(photo, existing.id);
        } catch (_) {}
        final updated = await FaceProfileStore.mergeInto(
          existing,
          newTemplates: [embedding],
          photoPath: photoPath,
        );
        _refreshProfiles();
        AppHelper().hideLoader();
        Get.snackbar(
          'Updated',
          '${updated.name} is already enrolled — updated their face '
              '(${updated.templates.length} samples).',
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
          'Failed to update: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          margin: const EdgeInsets.all(12),
        );
      }
      return;
    }

    final name = await _promptName();
    if (name == null) return; // cancelled

    AppHelper().showLoader();
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      String photoPath = '';
      try {
        photoPath = await FaceProfileStore.savePhoto(photo, id);
      } catch (_) {}
      await FaceProfileStore.add(FaceProfile(
        id: id,
        name: name,
        photoPath: photoPath,
        templates: [embedding],
      ));
      _refreshProfiles();
      AppHelper().hideLoader();
      Get.snackbar(
        'Face saved',
        '$name enrolled. You can now use live recognition.',
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
        'Failed to save: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  /// Prompts for a person's name. Returns the trimmed name (empty → "Person")
  /// or null if cancelled.
  Future<String?> _promptName() {
    final textController = TextEditingController();
    return Get.dialog<String?>(
      AlertDialog(
        title: const Text('Name this person'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(
              result: textController.text.trim().isEmpty
                  ? 'Person'
                  : textController.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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


