import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/wide_recipe_card.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../core/widgets/custom_icon_button/custom_icon_button.dart';
import '../../../core/widgets/custom_search_field/custom_search_field.dart';
import '../controller/search_controller.dart' as s;
import '../../recipes/widgets/filter_sheet.dart';
import '../../recipes/data/recipe_service.dart';

class SearchView extends GetView<s.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(
          onTap: () => Get.back(),
          iconColor: AppColors.iconColor,
          backgroundColor: AppColors.paleYellow,
        ),
        titleSpacing: 0,
        title: CustomSearchField(
          hintText: 'Search Recipes...',
          onChanged: (val) {
            RecipeService.to.searchQuery.value = val;
            if (val.isNotEmpty && !controller.recentSearches.contains(val)) {
              controller.recentSearches.insert(0, val);
            }
          },
          isSearch: true,
        ),
        actions: [
          CustomBackButton(
            onTap: () =>
                Get.bottomSheet(const FilterSheet(), isScrollControlled: true),
            iconColor: AppColors.iconColor,
            backgroundColor: AppColors.paleYellow,
            icon: Icons.tune,
          ),
        ],
      ),
      body: Obx(() {
        final status = RecipeService.to.status.value;

        // If the search bar is empty and there are no active filters, show recent history layout instead of filtered lists natively.
        if (RecipeService.to.searchQuery.value.isEmpty &&
            RecipeService.to.selectedCategory.value.isEmpty &&
            RecipeService.to.selectedPrepTime.value.isEmpty &&
            RecipeService.to.selectedDifficulty.value.isEmpty) {
          return _buildRecentSearches(theme);
        }

        if (status.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (status.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(status.errorMessage ?? "Error occurred"),
              ],
            ),
          );
        }

        if (status.isSuccess) {
          if (RecipeService.to.filteredRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text("No recipes found", style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  "Found ${RecipeService.to.filteredRecipes.length} results",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: RecipeService.to.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = RecipeService.to.filteredRecipes[index];
                    return WideRecipeCard(
                      title: recipe.title,
                      chefName: recipe.userDetails?.username ?? 'Unknown',
                      time: recipe.preparationTime,
                      servings: recipe.servings.toString(),
                      rating: '4.5',
                      image:
                          recipe.userDetails?.profilePicture ??
                          'assets/images/placeholder.jpg',
                      recipesImg: recipe.media?.isNotEmpty == true
                          ? recipe.media!
                          : 'assets/images/placeholder.jpg',
                      isSaved: recipe.isSaved,
                      onTap: () => Get.toNamed(
                        '/recipe-detail',
                        arguments: {'id': recipe.id},
                      ),
                      recipeId: recipe.id.toString(),
                      chefId: recipe.userId.toString(),
                      onSaveTap: () =>
                          RecipeService.to.saveRecipe(recipe.id.toString()),
                      onDeleteTap: () =>
                          RecipeService.to.deleteRecipe(recipe.id.toString()),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildRecentSearches(ThemeData theme) {
    if (controller.recentSearches.isEmpty) {
      return Center(
        child: Text(
          "Start searching for amazing recipes!",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Searches",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: const Text(
                  "Clear All",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.recentSearches.length,
            itemBuilder: (context, index) {
              final query = controller.recentSearches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.history,
                  color: Colors.grey,
                  size: 20,
                ),
                title: Text(
                  query,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  onPressed: () => controller.removeSearchItem(index),
                ),
                onTap: () {
                  // Trigger search with this query
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
