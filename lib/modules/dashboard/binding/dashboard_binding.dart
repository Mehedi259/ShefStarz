import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../recipes/data/recipe_service.dart';
import '../../home/data/home_service.dart';
import '../../../core/api/api_client.dart';
import '../../profile/data/profile_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../explore/controller/explore_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ExploreController>(() => ExploreController());

    // Core & Data
    Get.put(ApiClient());
    Get.put(RecipeService()); // Persistent service
    Get.put(HomeService());
    Get.put(ProfileService());
  }
}
