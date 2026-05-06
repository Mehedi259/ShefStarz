import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/cous.dart';
import '../controller/upload_controller.dart';

class UploadRecipeView extends GetView<UploadController> {
  const UploadRecipeView({super.key});

  void _showImagePickerSource(BuildContext context, int index) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text("Take Photo"),
              onTap: () {
                Get.back();
                controller.pickStepImage(index, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.orange),
              title: const Text("Pick from Gallery (Image/Video)"),
              onTap: () {
                Get.back();
                controller.pickStepImage(index, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          String title = "";
          switch (controller.currentRecipeStep.value) {
            case 0:
              title = "Intro to Recipe";
              break;
            case 1:
              title = "Ingredients & Steps";
              break;
          }
          return Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.orange,
            size: 25,
          ),
          onPressed: () {
            if (controller.currentRecipeStep.value > 0) {
              controller.recipePageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          Obx(() {
            // If we are at step 0, show the Next button
            if (controller.currentRecipeStep.value < 1) {
              return CustomGradientButton1(
                text: 'Next',
                width: 86,
                onTap: controller.nextRecipeStep,
              ).paddingOnly(right: 10);
            }

            // If we are at the final step, show the Publish button
            return SizedBox(
              width: 90, // Adjust width as needed for your AppBar action
              child: CustomGradientButton1(
                text: "Publish",
                isLoading: controller.isCreating.value,
                onTap: controller.publishRecipe,
              ),
            ).paddingOnly(right: 10);
          }),
        ],
      ),
      body: PageView(
        controller: controller.recipePageController,
        onPageChanged: (index) => controller.currentRecipeStep.value = index,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildDetailsStep(context), _buildStepsStep(context)],
      ),
    );
  }

  Widget _buildDetailsStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center(child: Text('Intro to Recipe')),
          _buildField(
            context,
            label: "Recipe Title",
            controller: controller.recipeTitle,
            hint: "eg. rainbow cake",
          ),
          const SizedBox(height: 24),
          Text(
            "Categories",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: Obx(
              () => ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: controller.categories.length,
                onReorder: controller.reorderCategories,
                proxyDecorator: (widget, index, animation) => widget,
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  return Padding(
                    key: ValueKey("cat_$index"),
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildChip(
                      context,
                      cat['name'],
                      Colors.orange,
                      cat['isSelected'],
                      cat['icon'],
                      index,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildField(
            context,
            label: "Description",
            controller: controller.recipeDescription,
            hint: "A rainbow cake is a vibrant...",
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          /* REPLACED WITH DROPDOWNS AS PER REQUEST */
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SERVES DROPDOWN ---
              Expanded(
                flex: 2, // Slightly adjusted ratio
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Serves",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.serves,
                      builder: (context, value, child) {
                        int? currentVal;
                        final match = RegExp(r'(\d+)').firstMatch(value.text);
                        if (match != null) {
                          currentVal = int.tryParse(match.group(1)!);
                        }

                        final options = [1, 2, 3, 4, 5, 6, 8, 10];
                        if (!options.contains(currentVal)) currentVal = null;

                        return DropdownButtonFormField<int>(
                          initialValue: currentVal,
                          isExpanded: true, // Prevents overflow from long text
                          isDense: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.cardColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, // Reduced slightly
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          hint: Text(
                            "Select",
                            style: theme.textTheme.bodySmall,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.orange,
                            size: 20,
                          ),
                          items: options.map((number) {
                            return DropdownMenuItem<int>(
                              value: number,
                              child: Text(
                                "$number ${number == 1 ? 'Pers.' : 'Ppl.'}", // Shortened for safety
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.serves.text = val.toString();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // --- COOK-TIME DROPDOWN ---
              Expanded(
                flex: 3, // Increased flex to accommodate dropdown
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cook-Time",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.cookTime,
                      builder: (context, value, child) {
                        final val = value.text;
                        final options = [
                          {"value": "under 10", "display": "Under 10 mins"},
                          {"value": "10-20", "display": "10-20 mins"},
                          {"value": "20-30", "display": "20-30 mins"},
                          {"value": "30+", "display": "30+ mins"},
                        ];
                        final isValid = options.any(
                          (opt) => opt["value"] == val,
                        );

                        return DropdownButtonFormField<String>(
                          initialValue: isValid ? val : null,
                          isExpanded: true,
                          isDense: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.cardColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          hint: Text(
                            "Select",
                            style: theme.textTheme.bodySmall,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.orange,
                            size: 20,
                          ),
                          items: options.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt["value"]!,
                              child: Text(
                                opt["display"]!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            if (newVal != null) {
                              controller.cookTime.text = newVal;
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "Ingredients",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.ingredients.length,
              onReorder: controller.reorderIngredients,
              itemBuilder: (context, index) {
                final ingController = controller.ingredients[index];
                return Padding(
                  key: ValueKey("ing_$index"),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_indicator,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: ingController,
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: "Ingredient name...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => controller.removeIngredient(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAddButton(
            context,
            label: "Add Ingredient",
            onTap: controller.addIngredient,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cooking Steps",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recipeSteps.length,
              onReorder: controller.reorderSteps,
              itemBuilder: (context, index) {
                final step = controller.recipeSteps[index];
                final descController =
                    step['description'] as TextEditingController;
                final imagePath = step['image'] as Rxn<String>;

                return Padding(
                  key: ValueKey("step_$index"),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_indicator,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: descController,
                                    maxLines: 3,
                                    style: theme.textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      hintText:
                                          "e.g Mix the flour and water...",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(() {
                                  if (imagePath.value != null) {
                                    final path = imagePath.value!;
                                    final isVideo =
                                        path.toLowerCase().endsWith('.mp4') ||
                                        path.toLowerCase().endsWith('.mov') ||
                                        path.toLowerCase().endsWith('.avi');

                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: isVideo
                                              ? Container(
                                                  height: 150,
                                                  width: double.infinity,
                                                  color: Colors.black87,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(
                                                        Icons.videocam,
                                                        color: Colors.orange,
                                                        size: 40,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Video Selected",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Image.file(
                                                  File(path),
                                                  height: 150,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: GestureDetector(
                                            onTap: () => imagePath.value = null,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return GestureDetector(
                                    onTap: () =>
                                        _showImagePickerSource(context, index),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.orange.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => controller.removeStep(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAddButton(
            context,
            label: "Add Step",
            onTap: controller.addStep,
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    Color color,
    bool isSelected,
    IconData icon,
    int index,
  ) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          controller.selectCategory(index);
        }
      },
      backgroundColor: theme.cardColor,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      avatar: Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? color : theme.dividerColor),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.paleYellow,

            borderRadius: BorderRadius.circular(30),
            // border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // removed updateCookTime func
}
