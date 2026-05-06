import 'package:get/get.dart';
import '../controller/notifications_controller.dart';
import '../data/repository/notification_repository.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
