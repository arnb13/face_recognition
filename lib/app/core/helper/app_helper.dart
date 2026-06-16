import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_pages.dart';
import 'auth_helper.dart';

class AppHelper {
  showLoader({bool dismissOnTap = true}) {
    EasyLoading.instance
      ..indicatorWidget = Container(
        height: 120,
        width: 120,
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: const SpinKitWaveSpinner(
          color: AppColors.primaryColor,
          size: 50.0,
        ),
        // child: Lottie.asset(Assets.lottieLoader,
        //     height: 120, width: 120, fit: BoxFit.fill),
      )
      ..loadingStyle = EasyLoadingStyle.custom
      ..textColor = Colors.white
      ..indicatorColor = Colors.transparent
      ..maskColor = Colors.transparent
      ..backgroundColor = Colors.transparent
      ..boxShadow = []
      ..contentPadding = EdgeInsets.zero
      ..radius = 5
      ..indicatorSize = 80.0
      ..userInteractions = false
      ..dismissOnTap = dismissOnTap;

    return EasyLoading.show();
  }

  hideLoader() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    // Navigator.of(context, rootNavigator: true).pop();
  }

  logout() {
    AuthHelper().clearUserData();
    Get.offAndToNamed(Routes.AUTH);
  }

  refreshLogin() async {
    // if (kDebugMode) {
    //   print(expiredTime.$.toString());
    //   print(timeDifference(expiredTime: expiredTime.$).toString());
    // }
    //
    // if (timeDifference(expiredTime: expiredTime.$) <= 0) {
    //   // var data = await AuthRepository().getRefreshToken();
    //   // await AuthHelper().clearUserData();
    //   // await AuthHelper().setUserData(data.data, true);
    // }
  }

  String getDayNameAndDateYearOnly(DateTime dateTime) {
    //Input: "2022-11-14 12:15:20"
    //Output: "12:15"
    return DateFormat('dd MMMM yyyy, EEEE').format(dateTime);
  }

  timeDifference({expiredTime}) {
    final expiredTimeData = DateTime.parse(expiredTime);
    final todayTime = DateTime.now();
    final difference = expiredTimeData.difference(todayTime).inMinutes;
    return difference;
  }

  getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  hideKeyboard() {
    // FocusManager.instance.primaryFocus?.unfocus();
    FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  Future<void> openUrl(url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  bool isKeyBoardVisible(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0 ? false : true;
  }

  String getFormattedDateOnly(DateTime dateTime,
      {isWeekDayNameOnly = false,
      isDateOnly = true,
      isDayNameAndDateOnly = false}) {
    if (isWeekDayNameOnly) {
      return DateFormat('EEEE').format(dateTime);
    } else if (isDateOnly) {
      return DateFormat('dd MMM, yyyy').format(dateTime);
    } else if (isDayNameAndDateOnly) {
      return DateFormat('EEEE').format(dateTime);
    }
    return DateFormat('EE, dd MMM, yyyy').format(dateTime);
  }

  String getDayAndMonthOnly(DateTime dateTime) {
    return DateFormat('dd MMM').format(dateTime);
  }

  String getDayNameOnly(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  scrollFlightListToTop(scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  // pickImageFromDevice({isCamera = false}) async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = isCamera
  //       ? await picker.pickImage(source: ImageSource.camera)
  //       : await picker.pickImage(source: ImageSource.gallery);
  //   return image?.path ?? null;
  // }
}
