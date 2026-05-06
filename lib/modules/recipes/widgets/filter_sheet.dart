import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/colors/custom_colors.dart';
import '../../recipes/data/recipe_service.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = RecipeService.to;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<MyColors>()?.customColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Text(
            "Filters",
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle(context, "Categories"),
                Obx(
                  () => _buildChipGroup(
                    context,
                    ["Breakfast", "Lunch", "Dinner", "Snacks"],
                    controller.selectedCategory.value,
                    (val) => _toggleFilter(controller.selectedCategory, val),
                    icons: [
                      Icons.breakfast_dining,
                      Icons.lunch_dining,
                      Icons.dinner_dining,
                      Icons.fastfood,
                    ],
                  ),
                ),

                Divider(height: 40, color: theme.dividerColor),

                _buildSectionTitle(context, "Time"),
                Obx(
                  () => _buildChipGroup(
                    context,
                    ["Under 10 Minutes", "10-20 Minutes", "20-30 minutes"],
                    controller.selectedPrepTime.value,
                    (val) => _toggleFilter(controller.selectedPrepTime, val),
                    icons: [Icons.access_time, null, null],
                    isTime: true,
                  ),
                ),

                Divider(height: 40, color: theme.dividerColor),

                _buildSectionTitle(context, "Recipes Difficulty"),
                Obx(
                  () => _buildChipGroup(
                    context,
                    ["Easy", "Medium", "Difficult"],
                    controller.selectedDifficulty.value,
                    (val) => _toggleFilter(controller.selectedDifficulty, val),
                  ),
                ),

                // _buildSectionTitle(context, "Location"),
                // Obx(
                //   () => Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     decoration: BoxDecoration(
                //       color: theme.dividerColor.withValues(alpha: 0.05),
                //       borderRadius: BorderRadius.circular(15),
                //       border: Border.all(
                //         color: theme.dividerColor.withValues(alpha: 0.1),
                //       ),
                //     ),
                //     child: DropdownButtonHideUnderline(
                //       child: DropdownButton<String>(
                //         value: controller.selectedLocation.value,
                //         isExpanded: true,
                //         dropdownColor: theme.cardColor,
                //         icon: Icon(
                //           Icons.keyboard_arrow_down,
                //           color: theme.primaryColor,
                //         ),
                //         style: theme.textTheme.bodyLarge,
                //         items: ["Global", "USA", "UK", "Bangladesh", "Turkey"]
                //             .map((String value) {
                //               return DropdownMenuItem<String>(
                //                 value: value,
                //                 child: Text(value),
                //               );
                //             })
                //             .toList(),
                //         onChanged: controller.setLocation,
                //       ),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 20),

                // Obx(
                //   () => CheckboxListTile(
                //     value: controller.isVerifiedOnly.value,
                //     onChanged: controller.toggleVerified,
                //     title: Text(
                //       "Verified Chefs Only",
                //       style: theme.textTheme.bodyLarge?.copyWith(
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     subtitle: Text(
                //       "Show recipes only from verified pro chefs",
                //       style: theme.textTheme.bodySmall,
                //     ),
                //     activeColor: theme.primaryColor,
                //     checkColor: Colors.white,
                //     contentPadding: EdgeInsets.zero,
                //     controlAffinity: ListTileControlAffinity.trailing,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 40),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Reset",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFilter(RxString observable, String value) {
    if (observable.value == value) {
      observable.value = '';
    } else {
      observable.value = value;
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChipGroup(
    BuildContext context,
    List<String> options,
    String selected,
    Function(String) onSelect, {
    List<IconData?>? icons,
    bool isTime = false,
  }) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isSelected = option == selected;
        IconData? icon;
        if (icons != null && index < icons.length) {
          icon = isTime ? Icons.access_time : icons[index];
        }

        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : theme.cardColor,
              // theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : theme.iconTheme.color?.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
