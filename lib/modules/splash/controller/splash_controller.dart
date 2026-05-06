import 'package:get/get.dart';
import '../../../data/repositories/app_repository.dart';
import '../../auth/data/auth_service.dart';

class SplashController extends GetxController {
  final AppRepository _appRepository = AppRepository();
  final appDetails = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _fetchAppDetails() async {
    try {
      final details = await _appRepository.getAppDetails();
      appDetails.value = details;
    } catch (e) {
      Get.log("Failed to fetch app details: $e");
    }
  }

  void _navigateToNext() async {
    _fetchAppDetails(); // Non-blocking
    await Future.delayed(const Duration(milliseconds: 500));
    await AuthService.to.checkLoginStatus();
  }
}
