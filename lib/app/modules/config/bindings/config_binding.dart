import 'package:get/get.dart';

import '../controllers/config_controller.dart';

class ConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfigController>(
      () => ConfigController(),
    );
  }
}
