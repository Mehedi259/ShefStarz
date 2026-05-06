import 'package:get/get.dart';
import '../../recipes/data/recipe_details_model.dart';
import '../../recipes/data/recipe_service.dart';

class ExploreController extends GetxController {
  final exploreRecipes = <RecipeDetailsModel>[].obs;
  final isLoading = false.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  // Filter States
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final selectedTime = ''.obs;
  final selectedDifficulty = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(RecipeService.to.recipes, (_) => applyFilters());
    applyFilters();
  }

  Future<void> fetchRecipes() async {
    // Relying on RecipeService to fetch globally
    if (RecipeService.to.recipes.isEmpty) {
      isLoading(true);
      await RecipeService.to.fetchRecipes();
      isLoading(false);
    } else {
      applyFilters();
    }
  }

  void applyFilters() {
    var results = RecipeService.to.recipes.toList();

    // 1. Search Query Filter
    if (searchQuery.value.trim().isNotEmpty) {
      final lowerQuery = searchQuery.value.toLowerCase();
      results = results.where((recipe) {
        return recipe.title.toLowerCase().contains(lowerQuery) ||
            recipe.description.toLowerCase().contains(lowerQuery) ||
            (recipe.userDetails?.username.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();
    }

    // 2. Category Filter
    if (selectedCategory.value.isNotEmpty) {
      final lowerCategory = selectedCategory.value.toLowerCase();
      results = results.where((recipe) {
        return recipe.description.toLowerCase().contains(lowerCategory) ||
            recipe.title.toLowerCase().contains(lowerCategory) ||
            recipe.category.toLowerCase().contains(
              lowerCategory,
            ) || // Using the real category field
            recipe.ingredients.any(
              (i) => i.name.toLowerCase().contains(lowerCategory),
            );
      }).toList();
    }

    // 3. Time Filter
    if (selectedTime.value.isNotEmpty) {
      final timeConstraint = selectedTime.value
          .toLowerCase()
          .replaceAll('minutes', '')
          .trim();
      results = results.where((recipe) {
        return recipe.preparationTime.toLowerCase().contains(timeConstraint);
      }).toList();
    }

    // 4. Difficulty Filter
    if (selectedDifficulty.value.isNotEmpty) {
      // Basic string match proxy
      final diffUpper = selectedDifficulty.value.toUpperCase();
      results = results.where((recipe) {
        return recipe.description.toUpperCase().contains(diffUpper) ||
            recipe.title.toUpperCase().contains(diffUpper);
      }).toList();
    }

    exploreRecipes.assignAll(results);
  }
}
