import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Face Recognition',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.pickImage();
                },
                child: const Text('Capture Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  controller.startLiveRecognition();
                },
                icon: const Icon(Icons.videocam),
                label: const Text('Start Live Recognition'),
              ),
            ],
          ),
        )),
    );
  }
}
