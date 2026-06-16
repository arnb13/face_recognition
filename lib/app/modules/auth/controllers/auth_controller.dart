import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_recognition/app/data/remote/repository/auth/auth_repository.dart';

import '../../../core/helper/app_widgets.dart';
import '../../../core/helper/auth_helper.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final  phoneController = TextEditingController().obs;
  final  passwordController = TextEditingController().obs;
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

  @override
  void onInit() {
    super.onInit();
    if(kDebugMode){
      /*phoneController.value.text = "01755534991";
      passwordController.value.text = "123456";*/

      //User
      /*phoneController.value.text = "01711184100";
      passwordController.value.text = "123456";*/

      //Admin
      phoneController.value.text = "01617143894";
      passwordController.value.text = "123456";
    }
  }

  void login() async {
    if (phoneController.value.text.isEmpty) {
      AppWidgets().getSnackBar(title: "Warning", message: 'Please fill up the phone number', backgroundColor: Colors.red);
      return;
    }

    if (passwordController.value.text.isEmpty) {
      AppWidgets().getSnackBar(title: "Warning", message: 'Please fill up the password', backgroundColor: Colors.red);
      return;
    }

    var response = await AuthRepository().getUserLogin(phoneController.value.text, passwordController.value.text);


    if (response.status == 'success') {
      await AuthHelper().setUserData(response, phoneController.value.text, DateTime.now().toIso8601String());
      Get.offAndToNamed(Routes.HOME);
      AppWidgets().getSnackBar(title: "Success", message: response.message);
    } else {
      AppWidgets().getSnackBar(title: "", message: response.message ?? 'Something went wrong. Please try again later');
    }
  }
}