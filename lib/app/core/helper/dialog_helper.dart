import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_constants.dart';
import '../style/app_colors.dart';
import '../style/app_style.dart';
import 'app_widgets.dart';
import 'debounce_helper.dart';


class DialogHelper {
  appExit(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              titlePadding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              title: Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 5),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/app_logo.png',
                      height: 35,
                      width: 35,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text("Alert!",
                        style: textRegularStyle(
                          color: Colors.black,
                        ))
                  ],
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Are you sure want to exit?',
                  style: textRegularStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    DebounceHelper().debounce(
                        time: 300,
                        tag: DebounceHelper.buttonTag,
                        onMethod: () {
                          Navigator.of(context).pop();

                          DebounceHelper().killAllDebounce();
                        });
                  },
                  child: Text(
                    'No',
                    style: textRegularStyle(color: AppColors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    DebounceHelper().debounce(
                        time: 300,
                        tag: DebounceHelper.buttonTag,
                        onMethod: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else {
                            exit(0);
                          }

                          DebounceHelper().killAllDebounce();
                        });
                  },
                  child: Text(
                    'Yes',
                    style: textRegularStyle(color: AppColors.black),
                  ),
                ),
              ],
            ));
  }

  customDialogBox(BuildContext context, title,
      {icon,
      leftButtonTitle = "No",
      rightButtonTitle = "Yes",
      leftButtonOnTap,
      rightButtonOnTap,
      isSvgIcon = false,
      hasCustomBody = false,
      body,
      isCenter = true}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              actionsAlignment:
                  isCenter ? MainAxisAlignment.center : MainAxisAlignment.end,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
              ),
              //titlePadding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              // contentPadding: const EdgeInsets.fromLTRB(mainInsidePadding*2.5,mainInsidePadding*2.5,mainInsidePadding,mainInsidePadding),
              /*title: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/app_logo.png',
                  height: 35,
                  width: 35,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text("Alert!",
                    style: TextStyle(
                      color: Colors.black,
                    ))
              ],
            ),
          ),*/
              content: !hasCustomBody
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isSvgIcon && icon != null
                            ? Image.asset(icon, width: 40, height: 40)
                            : isSvgIcon && icon != null
                                ? SvgPicture.asset(icon, width: 40, height: 40)
                                : const SizedBox(),
                        icon != null ? AppWidgets().gapH8() : const SizedBox(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 190.w,
                              child: Text(
                                title.toString(),
                                textAlign: TextAlign.center,
                                style: textRegularStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : body,
              //actionsPadding: EdgeInsets.fromLTRB(mainInsidePadding, mainInsidePadding, mainInsidePadding*2, mainInsidePadding*2),
              actions: <Widget>[
                leftButtonOnTap != null
                    ? buttonWidget(
                        onTap: () => leftButtonOnTap(),
                        title: leftButtonTitle,
                        anotherStyle: false)
                    : const SizedBox(),
                AppWidgets().gapW(1),
                rightButtonOnTap != null
                    ? buttonWidget(
                        onTap: () => rightButtonOnTap(),
                        title: rightButtonTitle,
                        anotherStyle: true)
                    : const SizedBox(),
              ],
            ));
  }

  customBackDialog(BuildContext context, title,
      {subTitle,
      icon,
      leftButtonTitle,
      rightButtonTitle,
      leftButtonOnTap,
      rightButtonOnTap,
      iconVisibility = true}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              actionsAlignment: MainAxisAlignment.center,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        iconVisibility
                            ? Image.asset(
                                icon,
                                width: 40,
                                height: 40,
                              )
                            : const SizedBox(),
                        iconVisibility
                            ? AppWidgets().gapH12()
                            : AppWidgets().gapH(2.0),
                        SizedBox(
                          width: 190.w,
                          child: Text(
                            title.toString(),
                            textAlign: TextAlign.center,
                            style: textRegularStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor),
                          ),
                        ),
                        subTitle != null
                            ? Container(
                                width: 190.w,
                                margin: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  subTitle.toString(),
                                  textAlign: TextAlign.center,
                                  style: textRegularStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.gray),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                  mainInsidePadding, 0.0, mainInsidePadding, 20.0),
              actions: <Widget>[
                leftButtonOnTap != null
                    ? buttonWidget(
                        onTap: () => leftButtonOnTap(),
                        title: leftButtonTitle.toString(),
                        anotherStyle: false)
                    : const SizedBox(),
                AppWidgets().gapW(1),
                rightButtonOnTap != null
                    ? buttonWidget(
                        onTap: () => rightButtonOnTap(),
                        title: rightButtonTitle.toString(),
                        anotherStyle: true)
                    : const SizedBox(),
              ],
            ));
  }

  customDialogBoxWithBody(BuildContext context, title,
      {subtitle,
      icon,
      isSvgIcon = false,
      body,
      barrierDismissal = true,
      contentPadding}) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissal,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
              ),
              contentPadding: contentPadding ??
                  const EdgeInsets.fromLTRB(
                      mainInsidePadding * 2.5,
                      mainInsidePadding * 2.5,
                      mainInsidePadding,
                      mainInsidePadding * 2.5),
              content: body,
            ));
  }

  buttonWidget({anotherStyle = false, title, onTap}) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: anotherStyle
                  ? AppColors.primaryColor
                  : Colors.transparent),
          gradient: RadialGradient(
            colors: anotherStyle
                ? [
                    AppColors.white,
                    AppColors.white,
                  ]
                : [
                    AppColors.primaryColor,
                    AppColors.primaryColor,
                  ],
            radius: 2.5,
          )),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DebounceHelper().debounce(
                time: 300,
                tag: DebounceHelper.buttonTag,
                onMethod: () {
                  onTap();
                  DebounceHelper().killAllDebounce();
                });
          },
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Text(
              title,
              style: textRegularStyle(
                  color: anotherStyle
                      ? AppColors.primaryColor
                      : AppColors.white,
                  fontWeight: FontWeight.bold),
            ),
          )),
        ),
      ),
    );
  }

/*  customWarningDialog(
    BuildContext context,
    String title,
    String subTitle, {
    leftButtonOnTap,
    rightButtonOnTap,
  }) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.zero, // Remove default padding

            backgroundColor: AppColors.transparentPure,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
            ),
            content: Container(
              height: 300.h,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Stack(
                fit: StackFit.loose,
                clipBehavior: Clip.antiAlias,
                // alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 200.h,
                        width: Get.width,
                        decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(19),
                              bottomRight: Radius.circular(19),
                            )),
                        child: Column(
                          children: [
                            AppWidgets().gapH(45),
                            Text(
                              title,
                              style: textRegularStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            AppWidgets().gapH8(),
                            Padding(
                              padding: REdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                subTitle,
                                textAlign: TextAlign.center,
                                style: textRegularStyle(),
                              ),
                            ),
                            AppWidgets().gapH(15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: leftButtonOnTap ?? () {},
                                  child: Container(
                                    padding: REdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.filterSectionColor,
                                      borderRadius: BorderRadius.circular(6.r),
                                      // border: Border.all(color: AppColors.primaryColor, width: 1.r)
                                    ),
                                    child: const Text(
                                      "No",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textColor),
                                    ),
                                  ),
                                ),
                                AppWidgets().gapW(20),
                                InkWell(
                                  onTap: rightButtonOnTap ?? () {},
                                  child: Container(
                                    padding: REdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonColor,
                                      borderRadius: BorderRadius.circular(6.r),
                                      // border: Border.all(color: AppColors.primaryColor, width: 1.r)
                                    ),
                                    child: const Text(
                                      "Yes",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: REdgeInsets.only(top: 60),
                      height: 85.h,
                      padding: REdgeInsets.all(5),
                      width: 85.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            85,
                          ),
                          border: Border.all(
                            color: AppColors.white,
                            // Custom border color
                            width: 2.0, // Custom border width
                          ),
                          color: AppColors.transparent),
                      child: Container(
                        alignment: Alignment.center,
                        height: 75.h,
                        width: 75.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(50)
                              .r, // Half of the height for a fully rounded container
                        ),
                        child: AnyImageView(
                          imagePath: Assets.svgWarning,
                          boxFit: BoxFit.fitHeight,
                          height: 30.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }*/
}
