import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import '../../home/data/home_service.dart';
import '../../recipes/data/recipe_service.dart';
import '../data/repository/upload_repository.dart';
import '../../auth/data/auth_service.dart';
import '../../home/data/user_details_model.dart';
import '../../home/data/post_model.dart';
import '../../../routes/app_pages.dart';
import '../../profile/controller/profile_controller.dart';
import '../../recipes/data/recipe_model.dart';
import '../../../core/widgets/parental_verification_dialog.dart';

class UploadController extends GetxController {
  final UploadRepository _repository = Get.find<UploadRepository>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isCreating = false.obs;

  // Camera
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final capturedImagePath = ''.obs;

  // Video Recording State
  final isVideoMode = false.obs;
  final isRecording = false.obs;
  final capturedVideoPath = ''.obs;
  VideoPlayerController? activeVideoController;

  // Camera Switching & Flash
  List<CameraDescription> availableCamerasList = [];
  final currentCameraIndex = 0.obs;
  final currentFlashMode = FlashMode.off.obs;

  // Selection
  final isPostTab = true.obs;
  final mediaCaptured = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      availableCamerasList = await availableCameras();
      if (availableCamerasList.isEmpty) return;

      cameraController = CameraController(
        availableCamerasList[currentCameraIndex.value],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await cameraController!.initialize();
      // Set initial flash mode if possible
      if (cameraController!.value.isInitialized) {
        try {
          await cameraController!.setFlashMode(currentFlashMode.value);
        } catch (_) {
          // Ignore if device doesn't support flash initially
        }
      }
      isCameraInitialized.value = true;
    } catch (e) {
      Get.log("Camera Error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (availableCamerasList.isEmpty || availableCamerasList.length < 2) return;
    if (isRecording.value) return; // Prevent switch while recording

    isCameraInitialized.value = false;
    await cameraController?.dispose();

    currentCameraIndex.value =
        (currentCameraIndex.value + 1) % availableCamerasList.length;

    // Reinitialize
    await initCamera();
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      FlashMode nextMode;
      switch (currentFlashMode.value) {
        case FlashMode.off:
          nextMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          nextMode = FlashMode.auto;
          break;
        case FlashMode.auto:
        case FlashMode.always:
          nextMode = FlashMode.off;
          break;
      }

      await cameraController!.setFlashMode(nextMode);
      currentFlashMode.value = nextMode;
    } catch (e) {
      // Gracefully handle if camera doesn't support flash (e.g. front camera)
      Get.snackbar(
        "Notice",
        "Flash not supported on this camera",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void toggleVideoMode() {
    if (isRecording.value) return; // Prevent changing mode while recording
    isVideoMode.value = !isVideoMode.value;
  }

  Future<void> captureMedia() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      // Fallback to image_picker if camera fails
      if (isVideoMode.value) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.camera,
        );
        if (video != null) {
          capturedVideoPath.value = video.path;
          mediaCaptured.value = true;
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1080,
        );
        if (image != null) {
          capturedImagePath.value = image.path;
          mediaCaptured.value = true;
        }
      }
      return;
    }

    try {
      if (isVideoMode.value) {
        if (isRecording.value) {
          // Stop recording
          final XFile videoFile = await cameraController!.stopVideoRecording();
          isRecording.value = false;
          capturedVideoPath.value = videoFile.path;
          mediaCaptured.value = true;
        } else {
          // Start recording
          await cameraController!.startVideoRecording();
          isRecording.value = true;
        }
      } else {
        final XFile image = await cameraController!.takePicture();
        capturedImagePath.value = image.path;
        mediaCaptured.value = true;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to capture media: $e");
    }
  }

  Future<void> pickFromGallery() async {
    try {
      if (isVideoMode.value) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
        if (video != null) {
          capturedVideoPath.value = video.path;
          mediaCaptured.value = true;
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1080,
        );
        if (image != null) {
          capturedImagePath.value = image.path;
          mediaCaptured.value = true;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick media: $e");
    }
  }

  @override
  void onClose() {
    stopActiveResources();
    cameraController?.dispose();
    postTitle.dispose();
    postDescription.dispose();
    recipeTitle.dispose();
    recipeDescription.dispose();
    serves.dispose();
    cookTime.dispose();
    for (var c in ingredients) {
      c.dispose();
    }
    for (var s in recipeSteps) {
      (s['description'] as TextEditingController).dispose();
    }
    super.onClose();
  }

  // Post Data
  final postTitle = TextEditingController();
  final postDescription = TextEditingController();

  // Recipe Data
  final recipePageController = PageController();
  final currentRecipeStep = 0.obs;

  // Recipe Form Fields
  final recipeTitle = TextEditingController();
  final recipeDescription = TextEditingController();
  final serves = TextEditingController();
  final cookTime = TextEditingController();

  // Categories (Reorderable)
  final categories = <Map<String, dynamic>>[
    {"name": "Breakfast", "icon": Icons.bakery_dining, "isSelected": true},
    {"name": "Lunch", "icon": Icons.rice_bowl, "isSelected": false},
    {"name": "Dinner", "icon": Icons.dinner_dining, "isSelected": false},
    {"name": "Snacks", "icon": Icons.fastfood, "isSelected": false},
  ].obs;

  // Ingredients (Reorderable with Forms)
  final ingredients = <TextEditingController>[].obs;

  // Steps (Reorderable with Images)
  final recipeSteps = <Map<String, dynamic>>[].obs;

  void toggleTab(bool isPost) {
    isPostTab.value = isPost;
  }

  void resetCapture() {
    stopActiveResources();
    mediaCaptured.value = false;
    capturedImagePath.value = '';
    capturedVideoPath.value = '';
    isRecording.value = false;
  }

  Future<void> stopActiveResources() async {
    // 1. Pause video playback if running
    if (activeVideoController != null &&
        activeVideoController!.value.isPlaying) {
      await activeVideoController!.pause();
    }

    // 2. Shut off flash if camera is active
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        if (currentFlashMode.value == FlashMode.torch ||
            currentFlashMode.value == FlashMode.always) {
          await cameraController!.setFlashMode(FlashMode.off);
          currentFlashMode.value = FlashMode.off;
        }
      } catch (_) {
        // Assume failure means it was safely disabled or unavailable
      }
    }
  }

  void nextRecipeStep() {
    if (currentRecipeStep.value < 1) {
      currentRecipeStep.value++;
      recipePageController.animateToPage(
        currentRecipeStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // REORDER LOGIC
  void reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
  }

  void reorderIngredients(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = ingredients.removeAt(oldIndex);
    ingredients.insert(newIndex, item);
  }

  void reorderSteps(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = recipeSteps.removeAt(oldIndex);
    recipeSteps.insert(newIndex, item);
  }

  // CATEGORY SELECTION
  void selectCategory(int index) {
    for (int i = 0; i < categories.length; i++) {
      categories[i]['isSelected'] = i == index;
    }
    categories.refresh();
  }

  // DYNAMIC ADD/REMOVE
  void addIngredient() {
    ingredients.add(TextEditingController());
  }

  void removeIngredient(int index) {
    ingredients[index].dispose();
    ingredients.removeAt(index);
  }

  void addStep() {
    recipeSteps.add({
      "description": TextEditingController(),
      "image": Rxn<String>(),
    });
  }

  void removeStep(int index) {
    (recipeSteps[index]['description'] as TextEditingController).dispose();
    recipeSteps.removeAt(index);
  }

  // MEDIA PICKING FOR STEPS
  Future<void> pickStepImage(int index, ImageSource source) async {
    try {
      XFile? media;
      if (source == ImageSource.gallery) {
        // Allow both images and videos from gallery
        media = await _picker.pickMedia(imageQuality: 70, maxWidth: 1080);
      } else {
        // Fallback to exactly Image for Camera, as pickMedia doesn't support Camera
        media = await _picker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1080,
        );
      }

      if (media != null) {
        (recipeSteps[index]['image'] as Rxn<String>).value = media.path;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick media: $e");
    }
  }

  Future<void> publishPost() async {
    final bool isVerified = await ParentalVerificationDialog.present();
    if (!isVerified) {
      Get.snackbar(
        'Notice',
        'Submission cancelled. Parent approval required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (postTitle.text.isEmpty) {
      Get.snackbar("Error", "Please enter a title");
      return;
    }

    // Validate Media
    final hasImage = capturedImagePath.value.isNotEmpty;
    final hasVideo = capturedVideoPath.value.isNotEmpty;

    if (!hasImage && !hasVideo) {
      Get.snackbar("Notice", "Please capture or select a photo/video first.");
      return;
    }

    final File mediaFile = File(
      hasVideo ? capturedVideoPath.value : capturedImagePath.value,
    );

    try {
      isLoading.value = true;
      final newPost = await _repository.uploadPost(
        title: postTitle.text,
        description: postDescription.text,
        media: mediaFile,
      );

      // Optimistic Reactive Update: Shift exactly onto Feed via HomeService
      if (newPost != null) {
        Post finalPost = newPost;

        if (finalPost.userDetails == null) {
          final currentUser = AuthService.to.currentUser.value;
          if (currentUser != null) {
            final mappedUserDetails = UserDetailsModel(
              id: int.tryParse(currentUser.id) ?? 0,
              email: currentUser.email,
              username: currentUser.name,
              profilePicture: currentUser.profilePicture,
              bio: currentUser.bio,
              isEmailVerified: currentUser.isEmailVerified,
              isParentApproved: currentUser.isParentApproved,
              followerCount: currentUser.followerCount,
              followingCount: currentUser.followingCount,
              postsCount: currentUser.postsCount,
              recipesCount: currentUser.recipesCount,
            );

            finalPost = Post(
              id: finalPost.id,
              chefName: currentUser.name,
              timeAgo: finalPost.timeAgo,
              title: finalPost.title,
              description: finalPost.description,
              likes: finalPost.likes,
              commentsCount: finalPost.commentsCount,
              image: finalPost.image,
              isLiked: finalPost.isLiked,
              isPinned: finalPost.isPinned,
              isSaved: finalPost.isSaved,
              postType: finalPost.postType,
              userDetails: mappedUserDetails,
              totalLikes: finalPost.totalLikes,
              totalComments: finalPost.totalComments,
              totalShares: finalPost.totalShares,
              totalPins: finalPost.totalPins,
              totalSaves: finalPost.totalSaves,
              likesList: finalPost.likesList,
              commentsList: finalPost.commentsList,
              sharesList: finalPost.sharesList,
              pinsList: finalPost.pinsList,
              savesList: finalPost.savesList,
              createdAt: finalPost.createdAt,
              updatedAt: finalPost.updatedAt,
            );
          }
        }

        try {
          final homeService = Get.find<HomeService>();
          homeService.feedPosts.insert(0, finalPost);
        } catch (_) {
          // HomeService might not be initialized if they jumped straight here, ignore safely
        }
      }

      // Task 2: Implement Navigation and Success Feedback
      postTitle.clear();
      postDescription.clear();
      resetCapture();

      Get.offAllNamed(Routes.DASHBOARD);
      Get.snackbar("Success", "Post uploaded successfully!");
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Upload timed out. Please check your internet connection and try again.",
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains('timeout')) {
        Get.snackbar(
          "Timeout",
          "Upload timed out. Please check your internet connection and try again.",
        );
      } else {
        Get.snackbar("Error", "Upload failed: ${e.toString()}");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> publishRecipe() async {
    final bool isVerified = await ParentalVerificationDialog.present();
    if (!isVerified) {
      Get.snackbar(
        'Notice',
        'Submission cancelled. Parent approval required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (recipeTitle.text.isEmpty) {
      Get.snackbar("Error", "Please enter a title");
      return;
    }

    final hasImage = capturedImagePath.value.isNotEmpty;
    final hasVideo = capturedVideoPath.value.isNotEmpty;

    if (!hasImage && !hasVideo) {
      Get.snackbar("Notice", "Please capture or select a photo/video first.");
      return;
    }

    final File mediaFile = File(
      hasVideo ? capturedVideoPath.value : capturedImagePath.value,
    );

    String selectedCategory = "snacks";
    try {
      final selected = categories.firstWhere((c) => c['isSelected'] == true);
      selectedCategory = selected['name'].toString().toLowerCase();
    } catch (_) {}

    try {
      isCreating.value = true;

      final ingredientsList = ingredients
          .map((c) => {"name": c.text, "amount": ""})
          .toList();

      final List<Map<String, dynamic>> stepsList = [];
      final List<http.MultipartFile> stepFiles = [];

      for (int i = 0; i < recipeSteps.length; i++) {
        final stepMap = recipeSteps[i];
        final description =
            (stepMap['description'] as TextEditingController).text;
        final stepImage = (stepMap['image'] as Rxn<String>).value;

        stepsList.add({
          "step": i + 1,
          "title": "Step ${i + 1}",
          "description": description,
        });

        // NOTE: The backend expects nested files mapped exactly through strings representing the index.
        // If this still returns null, we need to ask the backend developer exactly what form-data key string they configured DRF to accept for nested step images.
        if (stepImage != null && stepImage.isNotEmpty) {
          final fileKey = "steps[$i][image]";
          Get.log(
            "Attaching Step ${i + 1} Image to API via Key: '$fileKey' | Path: $stepImage",
          );
          stepFiles.add(await http.MultipartFile.fromPath(fileKey, stepImage));
        }
      }

      final newRecipe = await RecipeService.to.createRecipe(
        title: recipeTitle.text,
        description: recipeDescription.text,
        servings: serves.text.isEmpty
            ? "2"
            : serves.text.replaceAll(RegExp(r'[^0-9]'), ''),
        preparationTime: cookTime.text.isEmpty ? "10-20" : cookTime.text,
        category: selectedCategory,
        difficulty: "easy",
        ingredients: ingredientsList,
        frosting: [],
        steps: stepsList,
        media: mediaFile,
        extraFiles: stepFiles,
      );

      if (newRecipe != null) {
        try {
          RecipeService.to.fetchRecipes();
          HomeService.to.fetchFeed();
        } catch (_) {}

        // Optimistic UI Update: Profile Controller Data Sync
        if (Get.isRegistered<ProfileController>()) {
          try {
            final profileCtrl = Get.find<ProfileController>();

            // The list expects a primitive 'Recipe', so map 'RecipeDetailsModel' back down.
            final mappedRecipe = Recipe(
              id: newRecipe.id.toString(),
              title: newRecipe.title,
              chefName: AuthService.to.currentUser.value?.name ?? '',
              time: newRecipe.preparationTime,
              servings: newRecipe.servings.toString(),
              description: newRecipe.description,
              image: newRecipe.media ?? '',
              ingredients: newRecipe.ingredients.map((e) => e.name).toList(),
              steps: newRecipe.steps.map((s) {
                return RecipeStep(
                  title: s.title,
                  description: s.description,
                  image: s.image ?? '',
                );
              }).toList(),
            );

            profileCtrl.myRecipes.insert(0, mappedRecipe);
            // Updating the object count will be instantly noticed by the pre-configured `Obx` wrappers.
          } catch (e) {
            Get.log("Failed to sync Recipe with ProfileController: $e");
          }
        }

        recipeTitle.clear();
        recipeDescription.clear();
        serves.clear();
        cookTime.clear();
        for (var c in ingredients) {
          c.dispose();
        }
        ingredients.assignAll([]);

        for (var s in recipeSteps) {
          (s['description'] as TextEditingController).dispose();
        }
        recipeSteps.assignAll([]);

        resetCapture();

        Get.offAllNamed(Routes.DASHBOARD);
        Get.snackbar("Success", "Recipe uploaded successfully!");
      }
    } catch (e) {
      Get.log("Upload Error (Raw Backend response): $e");
      if (e.toString().toLowerCase().contains('timeout')) {
        Get.snackbar(
          "Timeout",
          "Upload timed out. Please check your internet connection and try again.",
        );
      } else {
        Get.snackbar("Error", "Upload failed: ${e.toString()}");
      }
    } finally {
      isCreating.value = false;
    }
  }
}
