import 'package:get/get.dart';
import '../data/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final isCheckingAuth = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      isCheckingAuth.value = true;
      
      // Check if user is already logged in
      final hasToken = await AuthService.to.hasValidToken();
      
      if (hasToken) {
        // User is logged in, redirect to dashboard
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        // User not logged in, stay on login screen
        isCheckingAuth.value = false;
      }
    } catch (e) {
      // Error checking auth, stay on login screen
      isCheckingAuth.value = false;
    }
  }
}
