import 'dart:math';

import 'package:flutter/widgets.dart';

enum DeviceType { phone, tablet }

class ScreenSizeHelper {
  static bool isTablet(MediaQueryData query) {
    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));

    /*
    print(
      'size: ${size.width}x${size.height}\n'
      'pixelRatio: ${query.devicePixelRatio}\n'
      'pixels: ${size.width * query.devicePixelRatio}x${size.height * query.devicePixelRatio}\n'
      'diagonal: $diagonal'
    );
    */

    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  DeviceType getDeviceType() {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  bool isPhone(context) {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.

    return shortestSide < 550;
  }

  getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
