import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../controller/recipe_cooking_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeCookingView extends GetView<RecipeCookingController> {
  const RecipeCookingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RecipeCookingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Recipe/ Steps",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF7D7D7D), size: 30),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 30),
          Expanded(
            child: Obx(() {
              if (controller.steps.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final step = controller.steps[controller.currentStepIndex.value];
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8A1F),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${controller.currentStepIndex.value + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (step.image.isEmpty)
                      const SizedBox.shrink()
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            (step.image.toLowerCase().endsWith('.mp4') ||
                                step.image.toLowerCase().endsWith('.avi') ||
                                step.image.toLowerCase().endsWith('.mov'))
                            ? Container(
                                height: 250,
                                width: double.infinity,
                                color: Colors.black87,
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white70,
                                    size: 60,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: step.image,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7D7D7D),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }),
          ),
          _buildBottomBar(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final totalSteps = controller.steps.length;
        if (totalSteps == 0) return const SizedBox.shrink();
        final currentStep = controller.currentStepIndex.value + 1;
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * (currentStep / totalSteps),
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Obx(() {
        if (controller.steps.isEmpty) return const SizedBox.shrink();

        final isLast = controller.isLastStep;
        final nextStepNum = controller.currentStepIndex.value + 2;

        if (isLast) {
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.previousStep,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Previous Step",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Finish Cooking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return GestureDetector(
          onTap: controller.nextStep,
          child: Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next Step-$nextStepNum",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
