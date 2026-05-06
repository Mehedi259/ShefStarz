import '../../core/api/api_client.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  final ApiClient _apiClient = ApiClient.to;

  Future<List<ActivityModel>> getRecentActivity() async {
    final response = await _apiClient.getRequest('activities');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching activities');
    }
    final List<dynamic> body = response.body;
    return body.map((e) => ActivityModel.fromJson(e)).toList();
  }
}
