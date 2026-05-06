import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../routes/app_pages.dart';
import '../data/recipe_model.dart';
import '../data/recipe_details_model.dart';
import '../data/recipe_service.dart';
import '../../home/controller/home_controller.dart';
import '../../home/data/home_service.dart';
import '../../home/data/interaction_action_model.dart';
import '../../auth/data/auth_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/custom_dialogs.dart';

class RecipeDetailController extends GetxController {
  final recipe = Rx<RecipeDetailsModel?>(null);
  final isLoading = true.obs;

  final commentController = TextEditingController();
  final isSubmittingComment = false.obs;

  final isPinned = false.obs;
  final isLiked = false.obs;
  final isSaved = false.obs;
  final isFollowing = false.obs;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  final isVideoInitialized = false.obs;

  @override
  void onClose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    commentController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    String id = '';

    if (args != null && args is Map && args.containsKey('id')) {
      id = args['id'].toString();
    } else if (args is Recipe) {
      id = args.id;
    } else if (args is String) {
      id = args;
    } else if (args is int) {
      id = args.toString();
    }

    if (id.isNotEmpty) {
      fetchRecipeDetails(id);
    } else {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid recipe ID');
    }
  }

  Future<void> fetchRecipeDetails(String id) async {
    isLoading.value = true;
    RecipeDetailsModel? details;
    try {
      final response = await ApiClient.to.getRequest('recipes/recipes/$id/');
      if (response.statusCode == 200 && response.body != null) {
        details = RecipeDetailsModel.fromJson(response.body);
        recipe.value = details;
      } else if (response.statusCode == 404) {
        Get.back();
        Get.snackbar(
          'Unavailable',
          'This content is no longer available or the user is blocked.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      } else {
        recipe.value = null;
      }
    } catch (e) {
      recipe.value = null;
    }

    if (details != null) {
      // 1. Proper State Initialization (Check if user exists in lists)
      final currentUserId = AuthService.to.currentUser.value?.id.toString();
      final currentUsername = AuthService.to.currentUser.value?.username;
      final currentUserEmail = AuthService.to.currentUser.value?.email ?? '';

      if (currentUserId != null && currentUserId.isNotEmpty) {
        isLiked.value =
            details.likesList.any(
              (like) =>
                  like.user == currentUserId ||
                  like.user == currentUsername ||
                  like.user == currentUserEmail,
            ) ||
            details.isLiked.value;

        isPinned.value =
            details.pinsList.any(
              (pin) =>
                  pin.user == currentUserId ||
                  pin.user == currentUsername ||
                  pin.user == currentUserEmail,
            ) ||
            details.isPinned.value;

        isSaved.value =
            details.savesList.any(
              (save) =>
                  save.user == currentUserId ||
                  save.user == currentUsername ||
                  save.user == currentUserEmail,
            ) ||
            details.isSaved.value;
      } else {
        isLiked.value = details.isLiked.value;
        isPinned.value = details.isPinned.value;
        isSaved.value = details.isSaved.value;
      }

      // Determine if we follow the chef
      if (Get.isRegistered<ProfileController>()) {
        final pc = Get.find<ProfileController>();
        isFollowing.value = pc.followingList.any(
          (user) => user.id == details!.userId.toString(),
        );
      }

      if (details.isVideo && details.media != null) {
        _initializeVideo(details.media!);
      }
    }

    isLoading.value = false;
  }

  Future<void> _initializeVideo(String url) async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await videoPlayerController!.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      isVideoInitialized.value = true;
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  void startCooking() {
    if (recipe.value != null && recipe.value!.steps.isNotEmpty) {
      final mappedSteps = recipe.value!.steps
          .map(
            (s) => RecipeStep(
              title: s.title,
              description: s.description,
              image: s.image ?? '',
            ),
          )
          .toList();
      Get.toNamed(Routes.RECIPE_COOKING, arguments: mappedSteps);
    } else {
      Get.snackbar("Info", "No steps available for this recipe.");
    }
  }

  Future<void> toggleLike() async {
    if (recipe.value != null) {
      final currentRecipe = recipe.value!;
      final bool wasLiked = isLiked.value;

      // Optimistic UI update
      isLiked.value = !wasLiked;
      if (isLiked.value) {
        currentRecipe.totalLikes.value += 1;
      } else {
        currentRecipe.totalLikes.value -= 1;
      }

      // API Call
      final success = await RecipeService.to.likeRecipe(
        currentRecipe.id.toString(),
      );
      if (!success) {
        // Revert on failure
        isLiked.value = wasLiked;
        if (wasLiked) {
          currentRecipe.totalLikes.value += 1;
        } else {
          currentRecipe.totalLikes.value -= 1;
        }
        Get.snackbar("Error", "Action failed. Please try again.");
      } else {
        // 2. Sync Back to Global List (Home Page)
        if (Get.isRegistered<HomeController>()) {
          final parentPostIndex = HomeService.to.feedPosts.indexWhere(
            (p) => p.id == currentRecipe.id.toString(),
          );
          if (parentPostIndex != -1) {
            final oldPost = HomeService.to.feedPosts[parentPostIndex];
            final newLikesList = List<InteractionActionModel>.from(
              oldPost.likesList ?? [],
            );
            final currentUserId =
                AuthService.to.currentUser.value?.id.toString() ?? '';
            final currentUser =
                AuthService.to.currentUser.value?.username ?? '';
            final currentUserEmail =
                AuthService.to.currentUser.value?.email ?? '';

            if (isLiked.value) {
              newLikesList.add(
                InteractionActionModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  user: currentUserEmail.isNotEmpty
                      ? currentUserEmail
                      : (currentUserId.isNotEmpty
                            ? currentUserId
                            : currentUser),
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );
            } else {
              newLikesList.removeWhere(
                (item) =>
                    item.user == currentUserId ||
                    item.user == currentUser ||
                    item.user == currentUserEmail,
              );
            }

            final updatedPost = oldPost.copyWith(
              isLiked: isLiked.value,
              likes: currentRecipe.totalLikes.value.toString(),
              totalLikes: currentRecipe.totalLikes.value,
              likesList: newLikesList,
            );
            HomeService.to.updateFeedPostLocally(updatedPost);
          }
        }
      }
    }
  }

  Future<void> togglePin() async {
    if (recipe.value != null) {
      final currentRecipe = recipe.value!;
      final bool wasPinned = isPinned.value;

      // Optimistic update
      isPinned.value = !wasPinned;

      final success = await RecipeService.to.pinRecipe(
        currentRecipe.id.toString(),
      );

      if (success) {
        if (isPinned.value) {
          currentRecipe.totalPins.value += 1;
        } else {
          currentRecipe.totalPins.value -= 1;
        }

        // Sync with RecipeService
        if (Get.isRegistered<RecipeService>()) {
          final index = RecipeService.to.recipes.indexWhere(
            (r) => r.id.toString() == currentRecipe.id.toString(),
          );
          if (index != -1) {
            RecipeService.to.recipes[index].isPinned.value = isPinned.value;
            RecipeService.to.recipes.refresh();
          }
        }

        // 2. Sync Back to Global List (Home Page Update)
        if (Get.isRegistered<HomeController>()) {
          final parentPostIndex = HomeService.to.feedPosts.indexWhere(
            (p) => p.id == currentRecipe.id.toString(),
          );
          if (parentPostIndex != -1) {
            final oldPost = HomeService.to.feedPosts[parentPostIndex];
            final newPinsList = List<InteractionActionModel>.from(
              oldPost.pinsList ?? [],
            );
            final currentUserId =
                AuthService.to.currentUser.value?.id.toString() ?? '';
            final currentUser =
                AuthService.to.currentUser.value?.username ?? '';
            final currentUserEmail =
                AuthService.to.currentUser.value?.email ?? '';

            if (isPinned.value) {
              newPinsList.add(
                InteractionActionModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  user: currentUserEmail.isNotEmpty
                      ? currentUserEmail
                      : (currentUserId.isNotEmpty
                            ? currentUserId
                            : currentUser),
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );
            } else {
              newPinsList.removeWhere(
                (item) =>
                    item.user == currentUserId ||
                    item.user == currentUser ||
                    item.user == currentUserEmail,
              );
            }

            final updatedPost = oldPost.copyWith(
              isPinned: isPinned.value,
              totalPins: currentRecipe.totalPins.value,
              pinsList: newPinsList,
            );
            HomeService.to.updateFeedPostLocally(updatedPost);

            // Explicitly call the refresh method as requested to ensure home list refreshes
            // the full list too without disrupting it
            HomeService.to.refreshFeedBackground();
          }
        }
      } else {
        // Revert Optimistic
        isPinned.value = wasPinned;
      }
    }
  }

  Future<void> toggleSave() async {
    if (recipe.value != null) {
      final currentRecipe = recipe.value!;
      final bool wasSaved = isSaved.value;

      // Optimistic update
      isSaved.value = !wasSaved;
      if (isSaved.value) {
        currentRecipe.totalSaves.value += 1;
      } else {
        currentRecipe.totalSaves.value -= 1;
      }

      final success = await RecipeService.to.saveRecipe(
        currentRecipe.id.toString(),
      );

      if (success) {
        // Sync Back to Global List (Home Page Update)
        if (Get.isRegistered<HomeController>()) {
          final parentPostIndex = HomeService.to.feedPosts.indexWhere(
            (p) => p.id == currentRecipe.id.toString(),
          );
          if (parentPostIndex != -1) {
            final oldPost = HomeService.to.feedPosts[parentPostIndex];
            final newSavesList = List<InteractionActionModel>.from(
              oldPost.savesList ?? [],
            );
            final currentUserId =
                AuthService.to.currentUser.value?.id.toString() ?? '';
            final currentUserEmail =
                AuthService.to.currentUser.value?.email ?? '';

            if (isSaved.value) {
              newSavesList.add(
                InteractionActionModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  user: currentUserEmail.isNotEmpty
                      ? currentUserEmail
                      : currentUserId,
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );
            } else {
              newSavesList.removeWhere(
                (item) =>
                    item.user == currentUserId || item.user == currentUserEmail,
              );
            }

            final updatedPost = oldPost.copyWith(
              isSaved: isSaved.value,
              totalSaves: currentRecipe.totalSaves.value,
              savesList: newSavesList,
            );
            HomeService.to.updateFeedPostLocally(updatedPost);
          }
        }
        // Sync with ProfileController to update "Saved" section instantly
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchSavedPosts();
        }
      } else {
        // Revert Optimistic
        isSaved.value = wasSaved;
        if (wasSaved) {
          currentRecipe.totalSaves.value += 1;
        } else {
          currentRecipe.totalSaves.value -= 1;
        }
      }
    }
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || recipe.value == null) return;

    isSubmittingComment.value = true;
    final success = await RecipeService.to.submitRecipeComment(
      recipe.value!.id.toString(),
      text,
    );
    isSubmittingComment.value = false;

    if (success) {
      commentController.clear();
      fetchRecipeDetails(recipe.value!.id.toString());
    }
  }

  bool get isMyRecipe {
    final currentUserId = AuthService.to.currentUser.value?.id.toString();
    return recipe.value?.userId.toString() == currentUserId;
  }

  void deleteRecipe() {
    CustomDialogs.showActionDialog(
      title: "Delete Recipe?",
      subtitle: "Are you sure you want to delete this recipe? This action cannot be undone.",
      confirmText: "Delete",
      isDestructive: true,
      icon: Icons.delete_outline,
      onConfirm: () async {
        Get.back(); // Close the dialog
        isLoading.value = true;

        try {
          final recipeId = recipe.value!.id.toString();
          final response = await ApiClient.to.deleteRequest(
            'recipes/recipes/$recipeId/',
          );

          // 204 No Content, 200 OK, or 404 Not Found (already deleted) are all considered success here
          if (response.statusCode == 200 ||
              response.statusCode == 204 ||
              response.statusCode == 404) {
            Get.snackbar("Success", "Recipe deleted successfully.");

            // FIX: Remove from Profile instantly
            if (Get.isRegistered<ProfileController>()) {
              final profileCtrl = Get.find<ProfileController>();
              profileCtrl.myRecipes.removeWhere(
                (r) => r.id.toString() == recipeId,
              );
              profileCtrl.fetchMyRecipes(); // Fetch fresh list from backend
            }

            // Remove from Global Recipe Service
            if (Get.isRegistered<RecipeService>()) {
              RecipeService.to.recipes.removeWhere(
                (r) => r.id.toString() == recipeId,
              );
              RecipeService.to.filteredRecipes.removeWhere(
                (r) => r.id.toString() == recipeId,
              );
            }

            // 3. Remove from Home explore/feed if applicable
            if (Get.isRegistered<HomeController>()) {
              HomeService.to.fetchFeed();
            }

            Get.back(); // Go back to the list screen
          } else {
            Get.snackbar("Error", "Failed to delete recipe. Please try again.");
          }
        } catch (e) {
          Get.snackbar("Error", "An error occurred.");
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> toggleFollowChef() async {
    if (recipe.value == null) return;
    final chefId = recipe.value!.userId.toString();

    // Optimistic update
    isFollowing.value = !isFollowing.value;

    try {
      final response = await ApiClient.to.postRequest(
        'users/profiles/$chefId/follow/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Option to refresh the Profile Controller lists if registered
        if (Get.isRegistered<ProfileController>()) {
          final currentUserId = AuthService.to.currentUser.value?.id;
          if (currentUserId != null) {
            Get.find<ProfileController>().loadFollowData(currentUserId);
          }
        }
      } else {
        isFollowing.value = !isFollowing.value;
        Get.snackbar("Error", "Failed to update follow status.");
      }
    } catch (e) {
      isFollowing.value = !isFollowing.value;
      Get.snackbar("Error", "Failed to update follow status.");
    }
  }
}
