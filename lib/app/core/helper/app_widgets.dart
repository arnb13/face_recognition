import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../style/app_colors.dart';
import '../style/app_style.dart';

class AppWidgets {
  Widget gapH(double height) {
    return SizedBox(
      height: height,
    );
  }

  Widget gapW(double width) {
    return SizedBox(
      width: width,
    );
  }

  Widget gapW8() {
    return const SizedBox(
      width: 8,
    );
  }

  Widget gapH8() {
    return const SizedBox(
      height: 8,
    );
  }

  Widget gapH16() {
    return const SizedBox(
      height: 16,
    );
  }

  Widget gapW16() {
    return const SizedBox(
      width: 16,
    );
  }

  Widget gapW12() {
    return const SizedBox(
      width: 12,
    );
  }

  Widget gapW24() {
    return const SizedBox(
      width: 24,
    );
  }

  Widget gapH12() {
    return const SizedBox(
      height: 12,
    );
  }

  Widget gapH24() {
    return const SizedBox(
      height: 24,
    );
  }

  Widget settingScreenDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: AppColors.gray,
      ),
    );
  }

  SnackbarController getSnackBar(
      {title = "Info",
      message = " Some message",
      int waitingTime = 2,
      int animationDuration = 500,
      snackPosition = SnackPosition.TOP,
      Color backgroundColor = AppColors.primaryColor,
      double backgroundColorOpacity = .8,
      bool closeAllSnacks = true,
      colorText = AppColors.white}) {
    if (closeAllSnacks) {
      Get.closeAllSnackbars();
    }
    return Get.snackbar(title, message,
        snackPosition: snackPosition,
        duration: Duration(seconds: waitingTime),
        animationDuration: Duration(milliseconds: animationDuration),
        backgroundColor: backgroundColor.withOpacity(backgroundColorOpacity),
        colorText: colorText);
  }

  Widget authTopText({
    title = "Title",
    subTitle = "Sub Title",
  }) {
    return Column(
      children: [
        Text(
          title,
          style: textAppBarStyle(fontSize: 16),
        ),
        AppWidgets().gapH(4),
        Text(
          subTitle,
          style: textRegularStyle(fontSize: 10),
        ),
      ],
    );
  }

// button
  myTextButton(BuildContext context, title,
      {callBack,
      bool isPrefixTextRequired = false,
      prefixText,
      double fontSize = 14,
      isUnderline = false,
      FontWeight fontWeight = FontWeight.normal,
      textColor = AppColors.primaryColor,
      bool isCenterAlign = true}) {
    return Row(
      mainAxisAlignment:
          isCenterAlign ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        Text(isPrefixTextRequired ? prefixText : "",
            style: textRegularStyle(
                color: AppColors.black,
                fontWeight: fontWeight,
                fontSize: fontSize.sp)),
        TextButton(
            onPressed: () {
              callBack();
            },
            child: Text(
              title,
              style: textRegularStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize.sp)
                  .copyWith(
                decoration: isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            )),
      ],
    );
  }

  mySvgIconButton(BuildContext context, {required String imagePath, callBack}) {
    return InkWell(
      overlayColor: WidgetStateProperty.all<Color>(
          AppColors.primaryColor.withOpacity(.2)),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      onTap: () {
        callBack(context);
      },
      child: SvgPicture.asset(
        imagePath,
        height: 48,
        width: 48,
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(
      BuildContext context, String? message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(); //dismiss all previous snackBar flutter
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryColor.withOpacity(.8),
        content: Text(message!),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget settingScreenFocusedText(text) {
    return Container(
      width: Get.width,
      height: 35.h,
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              text,
              style: textRegularStyle(
                  isWhiteColor: false,
                  fontSize: 15,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingScreenNonFocusedText(text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.only(left: 12),
      width: double.infinity,
      height: 35.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              text,
              style: textRegularStyle(
                  isWhiteColor: false,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  // Widget settingScreenFocusedTextWithSwitch(text,switchValue){
  //   return  Container(
  //     width: Get.width,
  //     height: 35.h,
  //     decoration: const BoxDecoration(
  //         color: AppColors.white
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(left: 12),
  //           child: Text(text,style: textRegularStyle(isWhiteColor: false,fontSize: 16),textAlign: TextAlign.start,),
  //         ),
  //         Switch(
  //           inactiveTrackColor: AppColors.grayDark,
  //           activeColor: AppColors.textDeepBlue,
  //           value: switchValue,
  //           onChanged: (value) {
  //            switchValue = value;
  //           },
  //         ),
  //       ],
  //     ),
  //   );

  // }
  // Widget settingScreenFocusedTextWithIcon(text){
  //   return Container(
  //     width: double.infinity,
  //     height: 35.h,
  //     decoration: const BoxDecoration(
  //         color: AppColors.white
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(left: 12,right: 12),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //                Text(text,style: textRegularStyle(isWhiteColor: false,fontSize: 15,fontWeight: FontWeight.normal),textAlign: TextAlign.start,),
  //               const Icon(Icons.arrow_forward_ios,color: AppColors.black,size: 16,)
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget settingScreenFocusedTextWithSwitch(text, switchValue) {
    return Container(
      width: Get.width,
      height: 30.h,
      decoration: const BoxDecoration(color: AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              text,
              style: textButtonStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: AppColors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Switch(
            inactiveTrackColor: AppColors.white,
            activeColor: AppColors.black,
            value: switchValue,
            onChanged: (value) {
              switchValue = value;
            },
          ),
        ],
      ),
    );
  }

  Widget settingScreenFocusedTextWithIcon(text, {Function? function}) {
    return InkWell(
      onTap: () {
        if (function != null) {
          function();
        }
      },
      child: Container(
        width: double.infinity,
        height: 30.h,
        decoration: const BoxDecoration(color: AppColors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: textButtonStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.black,
                    size: 16,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingScreenFocusedDuoTextWithIcon(primary, secondary) {
    return Container(
      width: double.infinity,
      height: 35.h,
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  primary,
                  style: textRegularStyle(
                      isWhiteColor: false,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.start,
                ),
                Row(
                  children: [
                    Text(
                      secondary,
                      style:
                          textRegularStyle(isWhiteColor: false, fontSize: 16),
                      textAlign: TextAlign.start,
                    ),
                    AppWidgets().gapW(6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.black,
                      size: 16,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget socialIconsViewer(context, {required imagePath}) {
    return SizedBox(
      height: 40,
      width: 40,
      child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          child: CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                imagePath,
                height: 48,
                width: 48,
              ),
            ),
          )),
    );
  }

  bannedUserDialog({required message}) {
    Get.defaultDialog(
        title: 'Attention',
        titlePadding: EdgeInsets.only(top: 10.h),
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        backgroundColor: AppColors.white,
        cancelTextColor: AppColors.black,
        confirmTextColor: AppColors.black,
        buttonColor: AppColors.black,
        barrierDismissible: true,
        radius: 10,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text(
              "Ok",
              style: TextStyle(color: AppColors.white),
            ),
            onPressed: () => Get.back(),
          ),
        ],
        content: SizedBox(
          height: 50.h,
          width: 200.h,
          child: Center(
              child: Text(
            message,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          )),
        ));
  }
}
