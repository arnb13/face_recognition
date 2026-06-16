import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:face_recognition/app/core/helper/app_widgets.dart';
import '../../../core/style/app_colors.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Portable Attendance System',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(
                width: 200.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Divider(
                        color: AppColors.primaryColor,
                        thickness: 3.h,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CircleAvatar(
                        radius: 4.r,
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Divider(
                        color: AppColors.primaryColor,
                        thickness: 3.h,
                      ),
                    ),
                  ],
                ),
              ),
              AppWidgets().gapH(50),
              TextField(
                controller: controller.phoneController.value,
                keyboardType: .phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined,
                      color: AppColors.primaryColor),
                  labelText: 'Phone Number',
                ),
              ),
              AppWidgets().gapH16(),
              ValueListenableBuilder(
                valueListenable: controller.isPasswordVisible,
                builder: (context, value, child) {
                  return TextField(
                    controller: controller.passwordController.value,
                    obscureText: !value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primaryColor),
                      labelText: 'Password',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: FaIcon(
                            value
                                ? FontAwesomeIcons.eyeSlash
                                : FontAwesomeIcons.eye,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            controller.isPasswordVisible.value = !value;
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              AppWidgets().gapH24(),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.login,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
