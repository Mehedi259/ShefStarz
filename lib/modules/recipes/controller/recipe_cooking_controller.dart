import 'package:get/get.dart';
import '../data/recipe_model.dart';

class RecipeCookingController extends GetxController {
  final currentStepIndex = 0.obs;
  final steps = <RecipeStep>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is List<RecipeStep>) {
      steps.assignAll(Get.arguments as List<RecipeStep>);
    } else {
      // Requested dummy data for Recipe Steps
      steps.assignAll([
        RecipeStep(
          title: "Prepare the Batter",
          description:
              "Ingredients: Flour, Sugar, Eggs, Butter. Mix all ingredients in a bowl until smooth.",
          image: "assets/images/girl_cooking.png",
        ),
        RecipeStep(
          title: "Add the Frosting",
          description:
              "Frosting: Chocolate, Vanilla, Strawberry. Choose your favorite flavor and apply it between the layers.",
          image: "assets/images/cake.png",
        ),
        RecipeStep(
          title: "Final Touch",
          description:
              "Complete the decoration and serve your delicious cake to your friends and family!",
          image: "assets/images/recepi1.png",
        ),
      ]);
    }
  }

  void nextStep() {
    if (currentStepIndex.value < steps.length - 1) {
      currentStepIndex.value++;
    }
  }

  void previousStep() {
    if (currentStepIndex.value > 0) {
      currentStepIndex.value--;
    }
  }

  void restart() {
    currentStepIndex.value = 0;
  }

  bool get isLastStep => currentStepIndex.value == steps.length - 1;
}
