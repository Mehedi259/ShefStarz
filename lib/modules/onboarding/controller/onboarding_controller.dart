import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/image/app_image.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  var pageIndex = 0.obs; // Use this as the single source of truth
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  // Update pageIndex when user swipes manually
  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  void nextPage(int totalPages) {
    if (pageIndex.value < totalPages - 1) {
      // pageController.nextPage will trigger onPageChanged automatically
      pageController.nextPage(
        duration: const Duration(
          milliseconds: 500,
        ), // 1000ms is a bit slow, 500ms is smoother
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(Routes.AUTH);
    }
  }

  final List<Map<String, dynamic>> onboardingPage = [
    {
      'image': MyAppImage.onbscreen1,
      'title': 'Cook. Create. Explore.',
      'desc': 'Jump into a world where kids can learn simple recipes...',
      'btnTitle': 'Next',
    },
    {
      'image': MyAppImage.onbscreen2,
      'title': 'Show Off Your Smart Chef Skills',
      'desc': 'Create your own cooking channel, upload photos...',
      'btnTitle': 'Next',
    },
    {
      'image': MyAppImage.onbscreen3,
      'title': 'Like, Follow, and Learn Together',
      'desc': 'Follow fellow junior chefs, drop likes...',
      'btnTitle': 'Get Started',
    },
  ];
}
