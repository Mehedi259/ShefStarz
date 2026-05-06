import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/recipe_details_model.dart';
import '../data/recipe_service.dart';

class EditRecipeController extends GetxController {
  final RecipeDetailsModel recipe;

  final isUpdating = false.obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final servingsController = TextEditingController();
  final prepTimeController = TextEditingController();
  final categoryController = TextEditingController();
  final difficultyController = TextEditingController();

  final mediaFile = Rxn<File>();

  // These can be modified further in a full view.
  final ingredientsList = <dynamic>[].obs;
  final frostingList = <dynamic>[].obs;
  final stepsList = <dynamic>[].obs;

  EditRecipeController({required this.recipe});

  @override
  void onInit() {
    super.onInit();
    _initFields();
  }

  void _initFields() {
    titleController.text = recipe.title;
    descriptionController.text = recipe.description;
    servingsController.text = recipe.servings.toString();
    prepTimeController.text = recipe.preparationTime;
    categoryController.text = recipe.category;
    difficultyController.text = recipe.difficulty;

    // Convert existing ingredients to simple lists or maps as appropriate
    ingredientsList.assignAll(
      recipe.ingredients
          .map((e) => {"name": e.name, "amount": e.amount})
          .toList(),
    );
    frostingList.assignAll(
      recipe.frosting.map((e) => {"name": e.name, "amount": e.amount}).toList(),
    );
    stepsList.assignAll(
      recipe.steps
          .map(
            (e) => {
              "step": e.step,
              "title": e.title,
              "description": e.description,
            },
          )
          .toList(),
    );
  }

  void setMediaFile(File file) {
    mediaFile.value = file;
  }

  Future<void> updateRecipe() async {
    isUpdating.value = true;
    try {
      // Create diffs
      String? updatedTitle;
      String? updatedDescription;
      String? updatedServings;
      String? updatedPrepTime;
      String? updatedCategory;
      String? updatedDifficulty;

      if (titleController.text.trim() != recipe.title) {
        updatedTitle = titleController.text.trim();
      }
      if (descriptionController.text.trim() != recipe.description) {
        updatedDescription = descriptionController.text.trim();
      }
      if (servingsController.text.trim() != recipe.servings.toString()) {
        updatedServings = servingsController.text.trim().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
      }
      if (prepTimeController.text.trim() != recipe.preparationTime) {
        updatedPrepTime = prepTimeController.text.trim();
      }
      if (categoryController.text.trim() != recipe.category) {
        updatedCategory = categoryController.text.trim();
      }
      if (difficultyController.text.trim() != recipe.difficulty) {
        updatedDifficulty = difficultyController.text.trim();
      }

      // Check lists (simple length check or assume changed if user adds/removes items).
      // For a true deep diff, we'd need more logic, but for now we'll just evaluate length
      // or assume the form logic will flag it. As an example, we patch it if length changes.
      List<dynamic>? updatedIngredients;
      List<dynamic>? updatedFrosting;
      List<dynamic>? updatedSteps;

      if (ingredientsList.length != recipe.ingredients.length) {
        updatedIngredients = ingredientsList;
      }
      if (frostingList.length != recipe.frosting.length) {
        updatedFrosting = frostingList;
      }
      if (stepsList.length != recipe.steps.length) {
        updatedSteps = stepsList;
      }

      final success = await RecipeService.to.partialUpdateRecipe(
        id: recipe.id.toString(),
        title: updatedTitle,
        description: updatedDescription,
        servings: updatedServings,
        preparationTime: updatedPrepTime,
        category: updatedCategory,
        difficulty: updatedDifficulty,
        ingredients: updatedIngredients,
        frosting: updatedFrosting,
        steps: updatedSteps,
        media: mediaFile.value,
      );

      if (success) {
        Get.back(result: true); // Return success to previous screen
      }
    } catch (e) {
      Get.log("Update exception: \$e");
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    servingsController.dispose();
    prepTimeController.dispose();
    categoryController.dispose();
    difficultyController.dispose();
    super.onClose();
  }
}
