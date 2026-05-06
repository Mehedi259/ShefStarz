import 'package:get/get.dart';
import '../data/notification_model.dart';
import '../data/repository/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  final notifications = <NotificationModel>[].obs;
  final status = RxStatus.success().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      status.value = RxStatus.loading();
      final data = await _repository.getNotifications();
      notifications.assignAll(data);
      status.value = data.isEmpty ? RxStatus.empty() : RxStatus.success();
    } catch (e) {
      status.value = RxStatus.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic UI update
    final originalList = List<NotificationModel>.from(notifications);
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );

    try {
      final success = await _repository.markAllAsRead();
      if (!success) {
        // Rollback if failed
        notifications.assignAll(originalList);
        Get.snackbar("Error", "Failed to mark all as read");
      }
    } catch (e) {
      notifications.assignAll(originalList);
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic UI update
    final index = notifications.indexOf(notification);
    if (index != -1) {
      notifications[index] = notification.copyWith(isRead: true);
    }

    try {
      final success = await _repository.markAsRead(notification.id);
      if (!success) {
        // Rollback
        if (index != -1) {
          notifications[index] = notification;
        }
        Get.snackbar("Error", "Failed to mark notification as read");
      }
    } catch (e) {
      if (index != -1) {
        notifications[index] = notification;
      }
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteNotification(String id) async {
    // Optimistic UI update
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final removedNotification = notifications[index];
    notifications.removeAt(index);

    try {
      final success = await _repository.deleteNotification(id);
      if (!success) {
        // Rollback
        notifications.insert(index, removedNotification);
        Get.snackbar("Error", "Failed to delete notification");
      }
    } catch (e) {
      notifications.insert(index, removedNotification);
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> getNotificationDetails(String id) async {
    try {
      isLoading.value = true;
      final details = await _repository.getNotificationDetails(id);
      // You can handle details here, e.g., show in a dialog or navigate
      Get.log("Notification details: ${details.message}");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
