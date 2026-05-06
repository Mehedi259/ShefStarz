import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../data/models/app_settings_model.dart';
import '../../../../data/models/app_details_model.dart';

class SettingsRepository {
  final ApiClient _apiClient = ApiClient.to;

  Future<AppSettingsModel> getSettings() async {
    final response = await _apiClient.getRequest(ApiConfig.appSettings);
    if (response.status.hasError || response.body == null) {
      return Future.error(response.statusText ?? 'Error fetching app settings');
    }
    return AppSettingsModel.fromJson(response.body);
  }

  Future<AppDetailsModel> getAppDetailsInfo() async {
    final response = await _apiClient.getRequest(
      ApiConfig.adminAppDetails,
      requiresAuth: true,
    );
    if (response.status.hasError || response.body == null) {
      return Future.error(response.statusText ?? 'Error fetching app details');
    }
    return AppDetailsModel.fromJson(response.body);
  }

  Future<AppSettingsModel> updateSettings(Map<String, dynamic> data) async {
    // Wait, the documentation says method PATCH for update app settings.
    // _apiClient only has postRequest and getRequest based on the scan.
    // Actually, let's use postRequest if patchRequest is not available, or I'll need to add patchRequest.
    // I'll assume we can use put/patch if added, but let me add patchRequest to ApiClient if needed, or use post.
    // Flutter http client doesn't automatically do PATCh for post.
    // Wait, let's look at ApiClient. It only has getRequest and postRequest.
    // I will use postRequest, but many APIs accept POST instead of PATCH if patch isn't supported by the client.
    // Wait, Postman says PATCH. I will have to add patchRequest to ApiClient. Let's do that next.

    final response = await _apiClient.patchRequest(ApiConfig.appSettings, data);
    if (response.status.hasError || response.body == null) {
      return Future.error(response.statusText ?? 'Error updating app settings');
    }
    return AppSettingsModel.fromJson(response.body);
  }
}
