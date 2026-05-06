import 'package:get/get.dart';
import 'recent_activity_controller.dart';

class RecentActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentActivityController>(() => RecentActivityController());
  }
}
