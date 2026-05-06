import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';

class AppRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getAppDetails() async {
    final response = await _apiClient.getRequest(
      ApiConfig.adminAppDetails,
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      if (response.body != null && response.body is Map) {
        return response.body;
      }
      return {};
    } else if (response.statusCode == 404) {
      // Gracefully handle 404 Not Found per user request
      return {"detail": "App details not found."};
    } else {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Failed to fetch app details");
    }
  }
}
