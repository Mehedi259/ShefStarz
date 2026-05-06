import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../home/data/post_model.dart';
import '../data/profile_service.dart';
import '../../../core/api/api_client.dart';
import '../controller/profile_controller.dart';
import '../../recipes/data/recipe_model.dart';
import '../../../data/services/api_service.dart';

class OtherProfileController extends GetxController {
  final String userId;
  OtherProfileController({required this.userId});

  Rxn<UserModel> userProfile = Rxn<UserModel>();
  RxBool isFollowing = false.obs;
  RxList<Post> userPosts = <Post>[].obs;
  RxList<Recipe> userRecipes = <Recipe>[].obs;
  RxList<UserModel> followersList = <UserModel>[].obs;
  RxList<UserModel> followingList = <UserModel>[].obs;

  RxBool isLoadingProfile = true.obs;
  RxBool isLoadingPosts = true.obs;
  RxBool isLoadingRecipes = true.obs;

  final ApiClient _apiClient = ApiClient();

  ApiService get _apiService {
    try {
      return Get.find<ApiService>();
    } catch (_) {
      return Get.put(ApiService());
    }
  }

  int get currentTargetUserId =>
      int.tryParse(Get.arguments?['userId']?.toString() ?? userId) ?? 0;

  @override
  void onInit() {
    super.onInit();
    int targetUserId = currentTargetUserId;
    if (targetUserId == 0) {
      Get.snackbar('Error', 'Invalid User ID');
      Get.back();
      return;
    }
    fetchProfileData(targetUserId);
  }

  Future<void> fetchProfileData(int targetUserId) async {
    // 1. Fetch Profile
    isLoadingProfile.value = true;
    _apiService.getOtherUserProfile(targetUserId).then((user) {
      if (user != null) {
        userProfile.value = user;
      }
      isLoadingProfile.value = false;
    });

    // 2. Fetch Posts
    isLoadingPosts.value = true;
    _apiService.getOtherUserPosts(targetUserId).then((posts) {
      userPosts.value = posts;
      isLoadingPosts.value = false;
    });

    // 3. Fetch Recipes
    isLoadingRecipes.value = true;
    _apiService.getOtherUserRecipes(targetUserId).then((recipes) {
      userRecipes.value = recipes;
      isLoadingRecipes.value = false;
    });

    // Fetch Followers / Following
    try {
      final followersRes = await _apiClient.getRequest(
        'users/profiles/$targetUserId/followers/',
      );
      if (followersRes.statusCode == 200) {
        final body = followersRes.body;
        if (body is List) {
          followersList.value = body.map((x) => UserModel.fromJson(x)).toList();
        } else if (body != null && body['results'] is List) {
          followersList.value = (body['results'] as List)
              .map((x) => UserModel.fromJson(x))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching followers: $e");
    }

    try {
      final followingRes = await _apiClient.getRequest(
        'users/profiles/$targetUserId/following/',
      );
      if (followingRes.statusCode == 200) {
        final body = followingRes.body;
        if (body is List) {
          followingList.value = body.map((x) => UserModel.fromJson(x)).toList();
        } else if (body != null && body['results'] is List) {
          followingList.value = (body['results'] as List)
              .map((x) => UserModel.fromJson(x))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching following: $e");
    }

    // Check following status
    try {
      final profileCtrl = Get.find<ProfileController>();
      isFollowing.value = profileCtrl.followingList.any(
        (u) => u.id.toString() == targetUserId.toString(),
      );
    } catch (e) {
      print('ProfileController not found');
    }
  }

  Future<void> toggleFollow() async {
    isFollowing.value = !isFollowing.value;
    final targetIdStr = currentTargetUserId.toString();
    bool success = await ProfileService.to.followUser(targetIdStr);
    if (!success) {
      isFollowing.value = !isFollowing.value;
      Get.snackbar("Error", "Action failed. Please try again.");
    } else {
      final user = userProfile.value;
      if (user != null) {
        final newCount = isFollowing.value
            ? user.followerCount + 1
            : (user.followerCount - 1 >= 0 ? user.followerCount - 1 : 0);
        userProfile.value = user.copyWith(followerCount: newCount);
      }
      try {
        final profileCtrl = Get.find<ProfileController>();
        profileCtrl.toggleFollow(targetIdStr);
      } catch (e) {}
    }
  }
}
