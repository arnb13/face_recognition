import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../connection_manager/connection_manager_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    ConnectionManagerBinding().dependencies();
    // Registered here (with fenix) so AuthController is always resolvable,
    // even if the per-page AuthBinding is missed during a rebuild/navigation
    // race. fenix recreates it on demand if it ever gets disposed.
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    // AirportSearchBinding().dependencies();
    // CalenderPickerBinding().dependencies();
    // HomeBinding().dependencies();
  }
}
