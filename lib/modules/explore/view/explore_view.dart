// import 'package:chef_starz/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_search_field/custom_search_field.dart';
import '../controller/explore_controller.dart';
import '../widget/explore_recipe_card.dart';
import '../../recipes/widgets/filter_sheet.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    ExploreController exploreController = Get.find<ExploreController>();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomSearchField(
                      hintText: 'Search Recipes...',
                      isSearch: true,
                      onChanged: (value) {
                        exploreController.searchQuery.value = value;
                        exploreController.applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune, color: Colors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Categories
              // SizedBox(
              //   height: 45,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: controller.categories.length,
              //     itemBuilder: (context, index) {
              //       return Obx(() {
              //         // FIX: Add .value here to compare the actual integer
              //         bool isSelected = controller.selectedIndex.value == index;
              //         return GestureDetector(
              //           onTap: () {
              //             // FIX: Add .value here to update the value
              //             controller.selectedIndex.value = index;
              //           },
              //           child: Container(
              //             width: 80,
              //             margin: EdgeInsets.symmetric(
              //               horizontal: 5,
              //               vertical: 3,
              //             ),
              //             decoration: BoxDecoration(
              //               // This will now update correctly because it's inside Obx
              //               color: isSelected
              //                   ? Colors.orange
              //                   : AppColors.paleYellow,
              //               borderRadius: BorderRadius.circular(10),
              //             ),
              //             child: Center(
              //               child: Text(
              //                 controller.categories[index],
              //                 style: TextStyle(
              //                   color: isSelected ? Colors.white : Colors.grey,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         );
              //       });
              //     },
              //   ),
              // ),
              // const SizedBox(height: 5),
              // Grid
              Expanded(
                child: Obx(() {
                  if (exploreController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }
                  if (exploreController.isError.value) {
                    return Center(
                      child: Text(
                        exploreController.errorMessage.value.isNotEmpty
                            ? exploreController.errorMessage.value
                            : "Error fetching recipes",
                      ),
                    );
                  }
                  if (exploreController.exploreRecipes.isEmpty) {
                    return const Center(child: Text("No recipes found"));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: exploreController.exploreRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = exploreController.exploreRecipes[index];
                      return ExploreRecipeCard(
                        recipe: recipe,
                        index: index,
                        onTap: () {
                          Get.toNamed(
                            '/recipe-detail',
                            arguments: {'id': recipe.id.toString()},
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }
}
