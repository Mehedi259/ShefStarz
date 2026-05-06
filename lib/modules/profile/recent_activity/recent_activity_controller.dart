import 'package:get/get.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/activity_repository.dart';

class RecentActivityController extends GetxController {
  final ActivityRepository _repository = ActivityRepository();

  final activities = <ActivityModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    isLoading.value = true;
    try {
      activities.value = await _repository.getRecentActivity();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
