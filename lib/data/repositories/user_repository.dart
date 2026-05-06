import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient.to;

  Future<UserModel> getUserProfile() async {
    final response = await _apiClient.getRequest(ApiConfig.profileMe);
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching profile');
    }
    return UserModel.fromJson(response.body);
  }

  Future<bool> updateProfile(UserModel user) async {
    final response = await _apiClient.postRequest(
      'profile/update',
      user.toJson(),
    );
    return !response.status.hasError;
  }

  Future<bool> updateLocation(String location) async {
    final response = await _apiClient.postRequest('profile/location', {
      'location': location,
    });
    return !response.status.hasError;
  }
}
