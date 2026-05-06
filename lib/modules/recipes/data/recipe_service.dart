import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../../home/data/interaction_action_model.dart';
import 'recipe_details_model.dart';
import '../../../../core/api/api_client.dart';
import '../../auth/data/auth_service.dart';
import '../../saved/controller/saved_controller.dart';

class RecipeService extends GetxService {
  static RecipeService get to => Get.find();

  final recipes = <RecipeDetailsModel>[].obs;
  final filteredRecipes = <RecipeDetailsModel>[].obs;
  final status = RxStatus.loading().obs;

  // Filter States
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final selectedDifficulty = ''.obs;
  final selectedPrepTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();

    // Debounce search query
    debounce(searchQuery, (_) => applyFilters(), time: 500.milliseconds);
  }

  Future<void> fetchRecipes({
    String? search,
    String? category,
    String? difficulty,
    String? prepTime,
  }) async {
    status.value = RxStatus.loading();
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category.toLowerCase();
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty.toLowerCase();
      }
      if (prepTime != null && prepTime.isNotEmpty) {
        // Format prepTime: lowercase and remove " minutes" or " Minutes"
        final formattedPrepTime = prepTime
            .toLowerCase()
            .replaceAll('minutes', '')
            .replaceAll('minute', '')
            .trim();
        queryParams['prep_time'] = formattedPrepTime;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      String path = 'recipes/recipes/';
      if (queryString.isNotEmpty) {
        path = '$path?$queryString';
      }

      final response = await ApiClient.to.getRequest(path);

      if (response.statusCode == 200) {
        if (response.body != null && response.body is List) {
          final currentEmail = AuthService.to.currentUser.value?.email ?? '';
          final currentUsername =
              AuthService.to.currentUser.value?.username ?? '';
          final currentId =
              AuthService.to.currentUser.value?.id.toString() ?? '';

          final list = (response.body as List).map((json) {
            final recipe = RecipeDetailsModel.fromJson(json);
            final isLiked = recipe.likesList.any(
              (like) =>
                  like.user == currentEmail ||
                  like.user == currentUsername ||
                  like.user == currentId,
            );
            final isPinned = recipe.pinsList.any(
              (pin) =>
                  pin.user == currentEmail ||
                  pin.user == currentUsername ||
                  pin.user == currentId,
            );
            final isSaved = recipe.savesList.any(
              (save) =>
                  save.user == currentEmail ||
                  save.user == currentUsername ||
                  save.user == currentId,
            );

            recipe.isLiked.value = isLiked || recipe.isLiked.value;
            recipe.isPinned.value = isPinned || recipe.isPinned.value;
            recipe.isSaved.value = isSaved || recipe.isSaved.value;

            return recipe;
          }).toList();
          recipes.assignAll(list);
          filteredRecipes.assignAll(list);
          if (recipes.isEmpty) {
            status.value = RxStatus.empty();
          } else {
            status.value = RxStatus.success();
          }
        } else {
          status.value = RxStatus.empty();
        }
      } else {
        status.value = RxStatus.error(response.statusText ?? "Failed to load");
      }
    } catch (e) {
      status.value = RxStatus.error(e.toString());
    }
  }

  void applyFilters() {
    fetchRecipes(
      search: searchQuery.value,
      category: selectedCategory.value,
      difficulty: selectedDifficulty.value,
      prepTime: selectedPrepTime.value,
    );
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedDifficulty.value = '';
    selectedPrepTime.value = '';
    applyFilters();
  }

  Future<bool> deleteRecipe(String id) async {
    try {
      final response = await ApiClient.to.deleteRequest('recipes/recipes/$id/');
      if (response.statusCode == 204) {
        recipes.removeWhere((r) => r.id.toString() == id);
        filteredRecipes.removeWhere((r) => r.id.toString() == id);
        Get.snackbar('Success', 'Recipe deleted successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to delete recipe');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error while deleting recipe');
      return false;
    }
  }

  Future<RecipeDetailsModel?> createRecipe({
    required String title,
    required String description,
    required String servings,
    required String preparationTime,
    required String category,
    required String difficulty,
    required List<dynamic> ingredients,
    required List<dynamic> frosting,
    required List<dynamic> steps,
    File? media,
    List<dynamic>? extraFiles,
  }) async {
    try {
      final fields = {
        'title': title,
        'description': description,
        'servings': servings.toString(),
        'preparation_time': preparationTime,
        'category': category,
        'difficulty': difficulty,
        'ingredients': jsonEncode(ingredients),
        'frosting': jsonEncode(frosting),
        'steps': jsonEncode(steps),
      };

      final response = await ApiClient.to.multipartRequest(
        'POST',
        'recipes/recipes/',
        fields,
        file: media,
        extraFiles: extraFiles?.cast(),
      );

      if (response.statusCode == 201) {
        final newRecipe = RecipeDetailsModel.fromJson(response.body);
        recipes.insert(0, newRecipe); // Add to the top of the feed
        return newRecipe;
      } else {
        Get.snackbar(
          'Error',
          'Failed to create recipe: ${response.statusText}',
        );
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while creating the recipe');
      return null;
    }
  }

  void addRecipe(RecipeDetailsModel recipe) {
    recipes.insert(0, recipe);
    filteredRecipes.insert(0, recipe);
  }

  RecipeDetailsModel? getRecipe(String id) {
    return recipes.firstWhereOrNull((r) => r.id.toString() == id);
  }

  Future<bool> likeRecipe(String recipeId) async {
    final recipeInList = getRecipe(recipeId);

    bool? previousState;
    int? previousCount;
    if (recipeInList != null) {
      // Optimistic Update
      previousState = recipeInList.isLiked.value;
      previousCount = recipeInList.totalLikes.value;
      recipeInList.isLiked.value = !previousState;
      recipeInList.totalLikes.value += recipeInList.isLiked.value ? 1 : -1;
    }

    try {
      final response = await ApiClient.to.postRequest(
        'recipes/recipes/$recipeId/like/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Revert
        if (recipeInList != null) {
          recipeInList.isLiked.value = previousState!;
          recipeInList.totalLikes.value = previousCount!;
        }
        Get.snackbar('Error', 'Failed to toggle like');
        return false;
      }
    } catch (e) {
      // Revert
      if (recipeInList != null) {
        recipeInList.isLiked.value = previousState!;
        recipeInList.totalLikes.value = previousCount!;
      }
      Get.snackbar('Error', 'Network error');
      return false;
    }
  }

  Future<bool> pinRecipe(String recipeId) async {
    final recipeInList = getRecipe(recipeId);

    bool? previousState;
    if (recipeInList != null) {
      // Optimistic Update
      previousState = recipeInList.isPinned.value;
      recipeInList.isPinned.value = !previousState;
    }

    try {
      final response = await ApiClient.to.postRequest(
        'recipes/recipes/$recipeId/pin/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Revert
        if (recipeInList != null) {
          recipeInList.isPinned.value = previousState!;
        }
        Get.snackbar('Error', 'Failed to pin recipe');
        return false;
      }
    } catch (e) {
      // Revert
      if (recipeInList != null) {
        recipeInList.isPinned.value = previousState!;
      }
      Get.snackbar('Error', 'Network error');
      return false;
    }
  }

  Future<bool> saveRecipe(String recipeId) async {
    final recipeInList = getRecipe(recipeId);

    bool? previousState;
    if (recipeInList != null) {
      // Optimistic Update
      previousState = recipeInList.isSaved.value;
      recipeInList.isSaved.value = !previousState;
    }

    try {
      final response = await ApiClient.to.postRequest(
        'recipes/recipes/$recipeId/save_recipe/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<SavedController>())
          SavedController.to.fetchSavedItems();
        return true;
      } else {
        // Revert
        if (recipeInList != null) {
          recipeInList.isSaved.value = previousState!;
        }
        Get.snackbar('Error', 'Failed to save recipe');
        return false;
      }
    } catch (e) {
      // Revert
      if (recipeInList != null) {
        recipeInList.isSaved.value = previousState!;
      }
      Get.snackbar('Error', 'Network error');
      return false;
    }
  }

  Future<bool> submitRecipeComment(String recipeId, String text) async {
    final recipe = getRecipe(recipeId);
    if (recipe == null) return false;

    try {
      final response = await ApiClient.to.postRequest(
        'recipes/recipes/$recipeId/add_comment/',
        {"comment": text},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body != null && response.body['comment'] != null) {
          final newComment = InteractionActionModel.fromJson(
            response.body['comment'],
          );
          recipe.commentsList.add(newComment);
          recipe.totalComments.value += 1;
          return true;
        } else {
          // fallback
          final newComment = InteractionActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            user: "You",
            createdAt: DateTime.now().toIso8601String(),
            comment: text,
          );
          recipe.commentsList.add(newComment);
          recipe.totalComments.value += 1;
          return true;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add comment: \${e.toString()}");
    }
    return false;
  }

  Future<RecipeDetailsModel?> getRecipeDetails(String id) async {
    try {
      final response = await ApiClient.to.getRequest('recipes/recipes/$id/');
      if (response.statusCode == 200) {
        if (response.body != null) {
          return RecipeDetailsModel.fromJson(response.body);
        }
      } else {
        Get.snackbar('Error', 'Failed to load recipe details');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error while fetching recipe details');
    }
    return null;
  }

  Future<bool> updateRecipe({
    required String id,
    required String title,
    required String description,
    required String servings,
    required String preparationTime,
    required String category,
    required String difficulty,
    required List<dynamic> ingredients,
    required List<dynamic> frosting,
    required List<dynamic> steps,
    File? media,
    List<dynamic>? extraFiles,
  }) async {
    try {
      final fields = {
        'title': title,
        'description': description,
        'servings': servings.toString(),
        'preparation_time': preparationTime,
        'category': category,
        'difficulty': difficulty,
        'ingredients': jsonEncode(ingredients),
        'frosting': jsonEncode(frosting),
        'steps': jsonEncode(steps),
      };

      final response = await ApiClient.to.putMultipartRequest(
        'recipes/recipes/$id/',
        fields,
        file: media,
        extraFiles: extraFiles?.cast(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Recipe updated successfully');
        // Fetch fresh details if requested, or just rely on the controller re-fetching it.
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update recipe: \${response.statusText}',
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while updating the recipe');
      return false;
    }
  }

  Future<bool> partialUpdateRecipe({
    required String id,
    String? title,
    String? description,
    String? servings,
    String? preparationTime,
    String? category,
    String? difficulty,
    List<dynamic>? ingredients,
    List<dynamic>? frosting,
    List<dynamic>? steps,
    File? media,
    List<dynamic>? extraFiles,
  }) async {
    try {
      final fields = <String, String>{};

      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (servings != null) fields['servings'] = servings.toString();
      if (preparationTime != null) fields['preparation_time'] = preparationTime;
      if (category != null) fields['category'] = category;
      if (difficulty != null) fields['difficulty'] = difficulty;

      if (ingredients != null) fields['ingredients'] = jsonEncode(ingredients);
      if (frosting != null) fields['frosting'] = jsonEncode(frosting);
      if (steps != null) fields['steps'] = jsonEncode(steps);

      final response = await ApiClient.to.patchMultipartRequest(
        'recipes/recipes/$id/',
        fields,
        file: media,
        extraFiles: extraFiles?.cast(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Recipe partially updated successfully');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update recipe: ${response.statusText}',
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while updating the recipe');
      return false;
    }
  }

  /// Removes all recipes from a specific user (used after blocking)
  void removeRecipesByUser(int userId) {
    recipes.removeWhere((r) => r.userId == userId);
    filteredRecipes.removeWhere((r) => r.userId == userId);
    recipes.refresh();
    filteredRecipes.refresh();
  }
}
