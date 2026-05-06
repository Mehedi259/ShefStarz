import 'package:get/get.dart';
import '../../modules/trust_and_safety/controller/trust_and_safety_controller.dart';

class ContentActionController extends GetxController {
  // We use TrustAndSafetyController for the real logic
  final TrustAndSafetyController _tsController = Get.put(TrustAndSafetyController());

  /// Calls the real API to report content
  Future<void> reportContent(String contentId, String reason, {String targetType = 'post'}) async {
    final intId = int.tryParse(contentId) ?? -1;
    if (intId == -1) {
      Get.snackbar('Error', 'Invalid content ID');
      return;
    }
    await _tsController.report(
      targetId: intId,
      targetType: targetType,
      reason: reason,
    );
  }

  /// Calls the real API to block a user
  Future<void> blockUser(String userId) async {
    final intId = int.tryParse(userId) ?? -1;
    if (intId == -1) {
      Get.snackbar('Error', 'Invalid user ID');
      return;
    }
    await _tsController.blockUser(intId);
  }

  /// Calls the real API to unblock a user
  Future<void> unblockUser(String userId) async {
    final intId = int.tryParse(userId) ?? -1;
    if (intId == -1) {
      Get.snackbar('Error', 'Invalid user ID');
      return;
    }
    await _tsController.unblockUser(intId);
  }
}
