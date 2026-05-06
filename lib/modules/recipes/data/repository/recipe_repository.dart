import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../recipe_model.dart';

abstract class IRecipeRepository {
  Future<List<Recipe>> getRecipes();
}

class RecipeRepository implements IRecipeRepository {
  final ApiClient _apiClient = ApiClient.to;

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      final response = await _apiClient.getRequest(ApiConfig.getRecipesList);
      if (response.statusCode == 200) {
        if (response.body is List) {
          return (response.body as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        } else if (response.body is Map && response.body['results'] is List) {
          return (response.body['results'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load recipes: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }
}
