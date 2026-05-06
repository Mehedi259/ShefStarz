import 'package:get/get.dart';
// ignore_for_file: constant_identifier_names

import '../modules/auth/view/parent_verification_view.dart';
import '../modules/auth/view/parent_view.dart';
import '../modules/auth/view/singup_verification_view.dart';
import '../modules/home/binding/home_binding.dart';
import '../modules/home/view/home_view.dart';
import '../modules/splash/binding/splash_binding.dart';
import '../modules/splash/view/splash_view.dart';
import '../modules/onboarding/binding/onboarding_binding.dart';
import '../modules/onboarding/view/onboarding_view.dart';
import '../modules/profile/edit_profile/edit_profile_binding.dart';
import '../modules/profile/edit_profile/edit_profile_view.dart';
import '../modules/profile/recent_activity/recent_activity_binding.dart';
import '../modules/profile/recent_activity/recent_activity_view.dart';
import '../modules/settings/location/location_binding.dart';
import '../modules/settings/location/location_view.dart';
import '../modules/legal/terms_view.dart';
import '../modules/legal/about_view.dart';
import '../modules/auth/binding/auth_binding.dart';
import '../modules/auth/view/auth_view.dart';
import '../modules/auth/view/login_view.dart';
import '../modules/dashboard/binding/dashboard_binding.dart';
import '../modules/dashboard/view/dashboard_view.dart';
import '../modules/auth/view/signup_details_view.dart';
import '../modules/auth/view/forgot_password_view.dart';
import '../modules/auth/view/verification_view.dart';
import '../modules/notifications/binding/notifications_binding.dart';
import '../modules/notifications/view/notifications_view.dart';
import '../modules/settings/binding/settings_binding.dart';
import '../modules/settings/view/settings_view.dart';
import '../modules/search/binding/search_binding.dart';
import '../modules/search/view/search_view.dart';
import '../modules/profile/view/followers_view.dart';
import '../modules/profile/view/following_view.dart';
import '../modules/saved/binding/saved_binding.dart';
import '../modules/saved/view/saved_view.dart';
import '../modules/saved/view/saved_details_view.dart';
import '../modules/upload/binding/upload_binding.dart';
import '../modules/upload/view/upload_selection_view.dart';
import '../modules/upload/view/upload_post_view.dart';
import '../modules/upload/view/upload_recipe_view.dart';
import '../modules/recipes/view/recipe_detail_view.dart';
import '../modules/recipes/view/recipe_cooking_view.dart';
import '../modules/home/controller/post_detail_controller.dart';
import '../modules/home/view/post_detail_view.dart';
import '../modules/profile/other_profile/other_profile_binding.dart';
import '../modules/profile/other_profile/other_profile_view.dart';
import '../modules/profile/other_profile/follow_network_view.dart';
import '../modules/profile/blocked_users/blocked_users_binding.dart';
import '../modules/profile/blocked_users/blocked_users_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();
  static const INITIAL = Routes.SPLASH;
  static final routes = [
    GetPage(
      name: Routes.POST_DETAIL,
      page: () => const PostDetailView(),
      binding: BindingsBuilder(() {
        Get.put(PostDetailController());
      }),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(), // Reuse AuthBinding
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(name: Routes.FOLLOWERS, page: () => const FollowersView()),
    GetPage(name: Routes.FOLLOWING, page: () => const FollowingView()),
    GetPage(
      name: Routes.SAVED,
      page: () => const SavedView(),
      binding: SavedBinding(),
    ),
    GetPage(
      name: Routes.SAVED_DETAILS,
      page: () => const SavedDetailsView(),
      binding: SavedBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.RECENT_ACTIVITY,
      page: () => const RecentActivityView(),
      binding: RecentActivityBinding(),
    ),
    GetPage(
      name: Routes.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(name: Routes.TERMS, page: () => const TermsView()),
    GetPage(name: Routes.ABOUT, page: () => const AboutView()),
    GetPage(
      name: Routes.UPLOAD,
      page: () => const UploadSelectionView(),
      binding: UploadBinding(),
    ),
    GetPage(
      name: Routes.UPLOAD_POST,
      page: () => const UploadPostView(),
      // Reuse binding or generic? Let's use same binding to share controller
      binding: UploadBinding(),
    ),
    GetPage(
      name: Routes.UPLOAD_RECIPE,
      page: () => const UploadRecipeView(),
      binding: UploadBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP_DETAILS,
      page: () => const SignupDetailsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.Parent_View,
      page: () => const ParentView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION,
      page: () => const VerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.PARENT_VERIFICATION,
      page: () => const ParentVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SINGUP_VERIFICATION,
      page: () => const SingUpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(name: Routes.RECIPE_DETAIL, page: () => const RecipeDetailView()),
    GetPage(name: Routes.RECIPE_COOKING, page: () => const RecipeCookingView()),
    GetPage(
      name: Routes.OTHER_PROFILE,
      page: () => const OtherProfileView(),
      binding: OtherProfileBinding(),
    ),
    GetPage(name: Routes.FOLLOW_NETWORK, page: () => const FollowNetworkView()),
    GetPage(
      name: Routes.BLOCKED_USERS,
      page: () => const BlockedUsersView(),
      binding: BlockedUsersBinding(),
    ),
  ];
}
