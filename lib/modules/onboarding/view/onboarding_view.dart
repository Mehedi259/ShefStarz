import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_btn.dart';
import '../../../core/widgets/indicator/indicator.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemCount: controller.onboardingPage.length,
          itemBuilder: (context, index) {
            final item = controller.onboardingPage[index];
            return _buildOnboardingPage(context, item, index);
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    return Column(
      children: [
        // Image Section with Skip and Indicator overlay
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),image: DecorationImage(image: AssetImage(item['image']),fit: BoxFit.cover)
                ),
              ),
              // Skip button and Indicator overlay
              Positioned(
                top: 16,
                left: 24,
                right: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Indicator.indicator(controller.pageController),
                    TextButton(
                      onPressed: () => Get.toNamed('/auth'),
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Text Content Section
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Description
                Column(
                  children: [
                    Text(
                      item['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item['desc']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                // Bottom Button
                Obx(() {
                  int currentIndex = controller.pageIndex.value;
                  return CustomGradientButton(
                    text: controller.onboardingPage[currentIndex]['btnTitle'],
                    onTap: () {
                      controller.nextPage(controller.onboardingPage.length);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
