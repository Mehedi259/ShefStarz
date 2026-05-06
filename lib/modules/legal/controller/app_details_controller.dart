import 'package:get/get.dart';
import '../../../data/models/app_details_model.dart';
import '../../settings/data/settings_repository.dart';

class AppDetailsController extends GetxController {
  final appDetails = Rxn<AppDetailsModel>();
  final isLoading = false.obs;
  final _repository = SettingsRepository();

  @override
  void onInit() {
    super.onInit();
    fetchAppDetails();
  }

  Future<void> fetchAppDetails() async {
    isLoading.value = true;
    try {
      final details = await _repository.getAppDetailsInfo();
      appDetails.value = details;
    } catch (e) {
      Get.log("Failed to fetch app details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
