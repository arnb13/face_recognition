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

  final easyLoadingBuilder = EasyLoading.init();

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
        // Edge-to-edge (required by Android 15 / targetSdk 35). The system
        // bars are transparent and the app draws behind them; a black surface
        // is painted behind the nav bar in the app builder below so it reads
        // as a solid black bar with white icons.
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ));

        return SharedValue.wrapApp(
          GetMaterialApp(
            title: "Face Recognition",
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.INITIAL,
            initialBinding: InitialBinding(),
            builder: (context, child) {
              // Apply EasyLoading, then paint a solid black surface behind the
              // transparent system navigation bar so edge-to-edge reads as a
              // black bar with white icons on Android 15+.
              final content = easyLoadingBuilder(context, child);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    Positioned.fill(child: content),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: MediaQuery.of(context).viewPadding.bottom,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primaryColor,
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryColor,
                surface: AppColors.surface,
                onSurface: AppColors.onSurface,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: AppColors.surface,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.onSurface,
                // AppBar overrides the global overlay style per route, so set
                // the dark-mode system bar style here too: transparent bars
                // with light (white) icons.
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                  systemNavigationBarContrastEnforced: false,
                ),
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
                  backgroundColor: AppColors.surfaceVariant,
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
