import 'package:get/get.dart';
import 'other_profile_controller.dart';

class OtherProfileBinding extends Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final userId = args?['userId']?.toString() ?? '0';

    Get.lazyPut<OtherProfileController>(
      () => OtherProfileController(userId: userId),
    );
  }
}
