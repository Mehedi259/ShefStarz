import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../models/user_model.dart';
import '../../modules/home/data/post_model.dart';
import '../../modules/recipes/data/recipe_model.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find<ApiService>();

  final ApiClient _apiClient = ApiClient();

  Future<UserModel?> getOtherUserProfile(int userId) async {
    try {
      final response = await _apiClient.getRequest('users/profiles/$userId/');
      if (response.statusCode == 200 && response.body != null) {
        return UserModel.fromJson(response.body);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  Future<List<Post>> getOtherUserPosts(int userId) async {
    try {
      final response = await _apiClient.getRequest(
        'posts/posts/?user_id=$userId',
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body is List) {
          return body.map((x) => Post.fromJson(x)).toList();
        } else if (body != null && body['results'] is List) {
          return (body['results'] as List)
              .map((x) => Post.fromJson(x))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching user posts: $e");
    }
    return [];
  }

  Future<List<Recipe>> getOtherUserRecipes(int userId) async {
    try {
      final response = await _apiClient.getRequest(
        'recipes/recipes/?user_id=$userId',
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body is List) {
          return body.map((x) => Recipe.fromJson(x)).toList();
        } else if (body != null && body['results'] is List) {
          return (body['results'] as List)
              .map((x) => Recipe.fromJson(x))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching user recipes: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDummyData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate latency
    return [
      {"id": 1, "name": "Chef Gordon", "image": ""},
      {"id": 2, "name": "Chef Jamie", "image": ""},
      {"id": 3, "name": "Chef Ramsay", "image": ""},
    ];
  }
}
