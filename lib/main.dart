import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:shared_value/shared_value.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';

import 'app/core/binding/initial_binding.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ScreenUtil.ensureScreenSize();
  runApp(ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ));

        return SharedValue.wrapApp(
          GetMaterialApp(
            title: "Portable Attendance System",
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.INITIAL,
            initialBinding: InitialBinding(),
            builder: EasyLoading.init(),
            theme: ThemeData(
              primaryColor: AppColors.primaryColor,
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide:
                      BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                focusColor: AppColors.primaryColor,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide:
                      BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            defaultTransition: Transition.cupertino,
            getPages: AppPages.routes,
            enableLog: kDebugMode,
          ),
        );
      }));
}
