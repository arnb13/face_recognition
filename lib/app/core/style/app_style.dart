import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'app_colors.dart';

TextStyle textHeaderStyle(
    {color = AppColors.textColor,
    double fontSize = 30,
    fontWeight = FontWeight.w700}) {
  return TextStyle(
      fontSize: fontSize.sp, color: color, fontWeight: fontWeight);
}

TextStyle textAppBarStyle(
    {color = AppColors.textColor,
    double fontSize = 16,
    fontWeight = FontWeight.w600,
    bool isGrayColor = false}) {
  return TextStyle(
      fontSize: fontSize.sp,
      color: isGrayColor ? AppColors.gray : color,
      fontWeight: fontWeight);
}

TextStyle textRegularStyle(
    {color = AppColors.textColor,
    double fontSize = 14,
    fontWeight = FontWeight.normal,
    bool isGrayColor = false,
    bool isWhiteColor = false}) {
  return TextStyle(
    fontSize: fontSize.sp,
    color: isWhiteColor
        ? AppColors.white
        : isGrayColor
            ? AppColors.gray
            : color,
    fontWeight: fontWeight,
    //height: needHeight ? 1.0 : 0.0
  );
}

TextStyle drawerTextStyle(
    {color = AppColors.black,
    double fontSize = 13,
    fontWeight = FontWeight.w500,
    bool isGrayColor = false,
    bool isWhiteColor = false}) {
  return TextStyle(
    fontSize: fontSize.sp,
    color: isWhiteColor
        ? AppColors.white
        : isGrayColor
            ? AppColors.gray
            : color,
    fontWeight: fontWeight,
    //height: needHeight ? 1.0 : 0.0
  );
}

TextStyle textButtonStyle(
    {color = AppColors.white,
    double fontSize = 18,
    fontWeight = FontWeight.w600}) {
  return TextStyle(
      fontSize: fontSize.sp, color: color, fontWeight: fontWeight);
}

TextStyle textLineStyle(
    {color = AppColors.textColor,
    double fontSize = 13,
    fontWeight = FontWeight.w600}) {
  return TextStyle(
      fontSize: fontSize.sp, color: color, fontWeight: fontWeight);
}

final hintStyle = TextStyle(
    fontSize: 14.sp, color: AppColors.gray, fontWeight: FontWeight.w500);
