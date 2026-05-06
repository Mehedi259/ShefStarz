import 'package:chef_starz/core/image/app_image.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs; // Default to the first item ("All")
  final List<String> categories = [
    "All",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Dessert",
    "Healthy",
    "Drinks",
  ];

  final List<String> images = [
    MyAppImage.cake,
    MyAppImage.recepi2,
    MyAppImage.recepi1,
    MyAppImage.search1,
    MyAppImage.search2,
    MyAppImage.search3,
    MyAppImage.profile1,
  ];
  final List<Map<String, dynamic>> recipesList = [
    {
      'recipesImg': 'https://placeholder.com/recipe1.jpg',
      'oner': 'https://placeholder.com/chef1.jpg',
    },
    {
      'recipesImg': 'https://placeholder.com/recipe2.jpg',
      'oner': 'https://placeholder.com/chef2.jpg',
    },
    {
      'recipesImg': 'https://placeholder.com/recipe3.jpg',
      'oner': 'https://placeholder.com/chef3.jpg',
    },
    {
      'recipesImg': 'https://placeholder.com/recipe4.jpg',
      'oner': 'https://placeholder.com/chef4.jpg',
    },
  ];

  final tabIndex = 0.obs;

  void setTabIndex(int index) {
    tabIndex.value = index;
  }

  @override
  void onClose() {
    // pageController.dispose();
    super.onClose();
  }
}
