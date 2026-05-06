import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.getRequest(ApiConfig.notifications);

    if (response.status.hasError) {
      return Future.error(
        response.statusText ?? "Error fetching notifications",
      );
    } else {
      final List<dynamic> data = response.body;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    }
  }

  Future<bool> markAllAsRead() async {
    final response = await _apiClient.postRequest(
      ApiConfig.markAllRead,
      {"is_read": true},
    );
    return !response.status.hasError;
  }

  Future<bool> markAsRead(String id) async {
    final response = await _apiClient.postRequest(
      ApiConfig.markRead(id),
      {"is_read": true},
    );
    return !response.status.hasError;
  }

  Future<bool> deleteNotification(String id) async {
    final response = await _apiClient.deleteRequest(
      ApiConfig.deleteNotification(id),
    );
    return !response.status.hasError;
  }

  Future<NotificationModel> getNotificationDetails(String id) async {
    final response = await _apiClient.getRequest(
      ApiConfig.getNotificationDetails(id),
    );

    if (response.status.hasError) {
      return Future.error(
        response.statusText ?? "Error fetching notification details",
      );
    } else {
      return NotificationModel.fromJson(response.body);
    }
  }
}
