import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/social_auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => SocialAuthController(), fenix: true);
  }
}
