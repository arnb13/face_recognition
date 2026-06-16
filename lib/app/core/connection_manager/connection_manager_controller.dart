import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../helper/print_log.dart';
import 'connection_type.dart';

class ConnectionManagerController extends GetxController {
  final isInternetConnected = true.obs;
  final connectedStatusMessage = "No Internet Connection".obs;
  final connectionType = ConnectionType.wifi.obs;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _getConnectivityType();
    _streamSubscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  @override
  void onClose() {
    _streamSubscription.cancel();

    printLog("On close initiated");
  }

  Future<void> _getConnectivityType() async {
    late List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      if (kDebugMode) {
        logger.d("PlatformException: $e");
      }
    }
    return _updateState(connectivityResult);
  }

  void _updateState(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.wifi)) {
      connectionType.value = ConnectionType.wifi;
      isInternetConnected.value = true;
      connectedStatusMessage.value = "Wifi Connected";
    } else if (result.contains(ConnectivityResult.mobile)) {
      connectionType.value = ConnectionType.mobileData;
      isInternetConnected.value = true;
      connectedStatusMessage.value = "Mobile Data Connected";
    } else {
      connectionType.value = ConnectionType.noInternet;
      isInternetConnected.value = false;
      connectedStatusMessage.value = "No Internet Connection";
    }
  }
}
