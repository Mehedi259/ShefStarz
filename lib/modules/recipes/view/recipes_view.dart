import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/filter_sheet.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/wide_recipe_card.dart';
import '../../../routes/app_pages.dart';
import '../data/recipe_service.dart';
import '../../../core/widgets/save_collection_bottom_sheet.dart';

class RecipesView extends StatelessWidget {
  const RecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Recipes",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.paleYellow),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        RecipeService.to.searchQuery.value = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Recipes...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        prefixIcon: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: const Icon(
                            Icons.search,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      const FilterSheet(),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paleYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: AppColors.iconColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Latest Recipes (1k+)",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final status = RecipeService.to.status.value;

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
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          status.errorMessage ?? "Error Loading",
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: RecipeService.to.fetchRecipes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Retry",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (status.isEmpty) {
                  return const Center(child: Text("No recipes found."));
                }

                return ListView.builder(
                  itemCount: RecipeService.to.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = RecipeService.to.filteredRecipes[index];
                    final imageSource =
                        recipe.userDetails?.profilePicture ??
                        'assets/images/placeholder.jpg';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WideRecipeCard(
                        title: recipe.title,
                        chefName: recipe.userDetails?.username ?? 'Unknown',
                        time: recipe.preparationTime,
                        servings: recipe.servings.toString(),
                        rating: '4.5',
                        image: imageSource,
                        recipesImg: recipe.media?.isNotEmpty == true
                            ? recipe.media!
                            : 'assets/images/placeholder.jpg',
                        onTap: () => Get.toNamed(
                          Routes.RECIPE_DETAIL,
                          arguments: {'id': recipe.id},
                        ),
                        recipeId: recipe.id.toString(),
                        chefId: recipe.userId.toString(),
                        isSaved: recipe.isSaved,
                        onSaveTap: () {
                          Get.bottomSheet(
                            SaveCollectionBottomSheet(
                              itemId: recipe.id.toString(),
                              onSaveToCollection: (collectionId) =>
                                  RecipeService.to.saveRecipe(
                                    recipe.id.toString(),
                                  ),
                            ),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
