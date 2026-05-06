import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../../home/view/home_view.dart';
import '../../explore/view/explore_view.dart';
import '../../recipes/view/recipes_view.dart';
import '../../profile/view/profile_view.dart';
import '../custom_buttom_nav/app_bottom_bar.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        return IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(),
            ExploreView(),
            RecipesView(),
            ProfileView(),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => AppBottomBar(
          tabIndex: controller.tabIndex.value,
          onPressed: (i) => controller.setTabIndex(i),
        ),
      ),
    );
  }
}
