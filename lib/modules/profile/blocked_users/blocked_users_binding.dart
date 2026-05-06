import 'package:get/get.dart';
import 'blocked_users_controller.dart';
import '../../trust_and_safety/controller/trust_and_safety_controller.dart';

class BlockedUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TrustAndSafetyController(), fenix: true);
    Get.lazyPut(() => BlockedUsersController());
  }
}
