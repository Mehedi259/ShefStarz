import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../recipes/data/recipe_model.dart';

class SearchRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<Recipe>> search(String query) async {
    final response = await _apiClient.getRequest(
      "${ApiConfig.search}?q=$query",
    );

    if (response.status.hasError) {
      return Future.error(response.statusText ?? "Error searching");
    } else {
      final List<dynamic> data = response.body;
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
  }
}
