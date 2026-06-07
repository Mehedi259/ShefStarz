import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/login_controller.dart';
import '../controller/social_auth_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    // Check if AuthController already exists, don't create duplicate
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut(() => AuthController());
    }
    if (!Get.isRegistered<SocialAuthController>()) {
      Get.lazyPut(() => SocialAuthController());
    }
  }
}
