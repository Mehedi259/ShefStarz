import 'dart:io';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../data/profile_service.dart';
import '../../auth/data/auth_service.dart';
import '../../home/data/repository/post_repository.dart';
import '../../home/data/post_model.dart';
import '../../recipes/data/recipe_model.dart';
import '../../../../core/api/api_client.dart';

class ProfileController extends GetxController {
  final isFollowing = false.obs;
  final followersList = <UserModel>[].obs;
  final followingList = <UserModel>[].obs;
  final isLoadingLists = false.obs;

  final isLoading = false.obs;
  final userId = 0.obs;
  final username = ''.obs;
  final location = ''.obs;

  final currentUser = Rxn<UserModel>();
  final isLoadingProfile = false.obs;

  final savedPosts = <Post>[].obs;
  final isLoadingSavedPosts = false.obs;
  final PostRepository _postRepository = PostRepository();

  // My Data
  final myPosts = <Post>[].obs;
  final isLoadingMyPosts = false.obs;
  final myRecipes = <Recipe>[].obs;
  final isLoadingMyRecipes = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    final user = AuthService.to.currentUser.value;
    if (user != null) {
      fetchSavedPosts();
    }
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    isLoadingProfile.value = true;
    try {
      final fetchedUser = await ProfileService.to.getUserProfile('me');
      if (fetchedUser != null) {
        currentUser.value = fetchedUser;
        AuthService.to.currentUser.value = fetchedUser;
        userId.value = int.tryParse(fetchedUser.id) ?? 0;
        username.value = fetchedUser.username;
        location.value = fetchedUser.location ?? '';

        fetchMyPosts();
        fetchMyRecipes();
        loadFollowData(fetchedUser.id);
      }
    } catch (e) {
      Get.log("Error fetching user profile: $e");
      Get.snackbar('Error', 'Failed to load profile data.');
    } finally {
      isLoading.value = false;
      isLoadingProfile.value = false;
    }
  }

  Future<void> updateUserLocation(String newLocation) async {
    if (userId.value == 0) return;
    try {
      final updatedUser = await ProfileService.to.updateUserProfile(
        userId.value.toString(),
        {'location': newLocation},
      );
      if (updatedUser != null) {
        location.value = newLocation;
        currentUser.value = updatedUser;
        AuthService.to.currentUser.value = updatedUser;
        Get.snackbar("Success", "Location updated successfully.");
      } else {
        Get.snackbar("Error", "Failed to update location.");
      }
    } catch (e) {
      Get.log("Error updating location: $e");
      Get.snackbar("Error", "Error updating location.");
    }
  }

  Future<void> refreshProfileData() async {
    await fetchUserProfile();
  }

  Future<bool> updateProfile(
    Map<String, dynamic> data, {
    File? profilePicture,
  }) async {
    final user = currentUser.value ?? AuthService.to.currentUser.value;
    if (user == null) return false;

    try {
      final updatedUser = await ProfileService.to.updateUserProfile(
        user.id,
        data,
        profilePicture: profilePicture,
      );
      if (updatedUser != null) {
        currentUser.value = updatedUser;
        AuthService.to.currentUser.value = updatedUser;
        return true;
      }
    } catch (e) {
      Get.log("Error updating profile: $e");
    }
    return false;
  }

  Future<void> loadFollowData(String userId) async {
    if (userId.trim().isEmpty) return;
    isLoadingLists.value = true;
    try {
      final followers = await ProfileService.to.getFollowers(userId);
      followersList.assignAll(followers);

      final following = await ProfileService.to.getFollowing(userId);
      followingList.assignAll(following);

      // Update the user count optimistically if viewing own profile
      final user = AuthService.to.currentUser.value;
      if (user != null && user.id == userId) {
        AuthService.to.currentUser.value = user.copyWith(
          followerCount: followers.length,
          followingCount: following.length,
        );
      }
    } catch (e) {
      Get.log("Error loading follow data: $e");
    } finally {
      isLoadingLists.value = false;
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    bool currentlyFollowing = isFollowing.value;
    isFollowing.value = !currentlyFollowing;

    bool success = false;
    if (currentlyFollowing) {
      success = await ProfileService.to.unfollowUser(targetUserId);
    } else {
      success = await ProfileService.to.followUser(targetUserId);
    }

    if (!success) {
      isFollowing.value = currentlyFollowing;
    } else {
      // FIX: Instantly refresh the current user's profile to update counts on the UI
      await fetchUserProfile();
      // Also refresh the follow lists
      final user = AuthService.to.currentUser.value;
      if (user != null) {
        await loadFollowData(user.id);
      }
    }
  }

  Future<void> fetchSavedPosts() async {
    isLoadingSavedPosts.value = true;
    try {
      final posts = await _postRepository.getSavedPosts();
      savedPosts.assignAll(posts);
    } catch (e) {
      Get.log("Error fetching saved posts: $e");
    } finally {
      isLoadingSavedPosts.value = false;
    }
  }

  Future<void> fetchMyPosts() async {
    if (userId.value == 0) return;
    isLoadingMyPosts.value = true;
    try {
      final res = await ApiClient.to.getRequest(
        'posts/posts/?user_id=${userId.value}',
      );
      if (res.statusCode == 200 && res.body is List) {
        myPosts.assignAll(
          (res.body as List).map((e) => Post.fromJson(e)).toList(),
        );
      } else if (res.statusCode == 200 &&
          res.body is Map &&
          res.body['results'] is List) {
        myPosts.assignAll(
          (res.body['results'] as List).map((e) => Post.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.log("Error fetching my posts: $e");
    } finally {
      isLoadingMyPosts.value = false;
    }
  }

  Future<void> fetchMyRecipes() async {
    final currentUserId = AuthService.to.currentUser.value?.id;
    if (currentUserId == null) return;
    isLoadingMyRecipes.value = true;
    myRecipes
        .clear(); // Clear local list while fetching to avoid ghost/deleted recipes
    try {
      final res = await ApiClient.to.getRequest(
        'recipes/recipes/?user_id=$currentUserId',
      );
      if (res.statusCode == 200 && res.body is List) {
        myRecipes.assignAll(
          (res.body as List).map((e) => Recipe.fromJson(e)).toList(),
        );
      } else if (res.statusCode == 200 &&
          res.body is Map &&
          res.body['results'] is List) {
        myRecipes.assignAll(
          (res.body['results'] as List).map((e) => Recipe.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.log("Error fetching my recipes: $e");
    } finally {
      isLoadingMyRecipes.value = false;
    }
  }
}
