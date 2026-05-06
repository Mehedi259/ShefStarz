import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../controller/recipe_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/recipe_details_model.dart';
import '../../../core/widgets/save_collection_bottom_sheet.dart';

class RecipeDetailView extends GetView<RecipeDetailController> {
  const RecipeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded if not already
    Get.put(RecipeDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final details = controller.recipe.value;
        if (details == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Recipe not found or has been deleted.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(details),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChefInfo(details),
                    const SizedBox(height: 20),
                    Text(
                      details.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStats(details),
                    const SizedBox(height: 25),
                    _buildActionButtons(details),
                    const SizedBox(height: 30),
                    const Text(
                      "Ingredients",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildIngredientList(details),
                    const SizedBox(height: 25),
                    const Text(
                      "Frosting",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFrostingList(details),
                    if (details.steps.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      const Text(
                        "Steps/Instructions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildStepsList(details),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(RecipeDetailsModel recipeDetails) {
    return Stack(
      children: [
        if (recipeDetails.isVideo)
          Obx(() {
            if (controller.isVideoInitialized.value &&
                controller.chewieController != null) {
              return SizedBox(
                height: 300,
                width: double.infinity,
                child: Chewie(controller: controller.chewieController!),
              );
            }
            return Container(
              width: double.infinity,
              height: 300,
              color: Colors.black87,
              child: const Center(child: CircularProgressIndicator()),
            );
          })
        else if ((recipeDetails.media ?? '').startsWith('assets/'))
          Image.asset(
            recipeDetails.media!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),
          )
        else
          CachedNetworkImage(
            imageUrl: recipeDetails.media ?? '',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),
          ),
        Positioned(
          top: 50,
          left: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9EDC3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFFFF8A1F),
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: Row(
            children: [
              Obx(() {
                final isPinned = controller.isPinned.value;
                return GestureDetector(
                  onTap: controller.togglePin,
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? const Color(0xFFFF8A1F) : Colors.white,
                    size: 24,
                  ),
                );
              }),
              const SizedBox(width: 15),
              Obx(() {
                final isSaved = controller.isSaved.value;
                return GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      SaveCollectionBottomSheet(
                        itemId: controller.recipe.value?.id.toString() ?? '',
                        onSaveToCollection: (collectionId) {
                          controller.toggleSave();
                        },
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? const Color(0xFFFF8A1F) : Colors.white,
                    size: 28,
                  ),
                );
              }),
              const SizedBox(width: 15),
              Obx(() {
                final isMine = controller.isMyRecipe;
                final isFollowing = controller.isFollowing.value;

                return PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'delete') controller.deleteRecipe();
                    if (value == 'follow') controller.toggleFollowChef();
                  },
                  itemBuilder: (context) => [
                    if (isMine)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          "Delete Recipe",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (!isMine)
                      PopupMenuItem(
                        value: 'follow',
                        child: Text(
                          isFollowing ? "Unfollow Chef" : "Follow Chef",
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChefInfo(RecipeDetailsModel recipeDetails) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EDC3), // Cream color from Image 3
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                (recipeDetails.userDetails?.profilePicture ?? '').startsWith(
                  'assets/',
                )
                ? Image.asset(
                    recipeDetails.userDetails!.profilePicture!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                  )
                : CachedNetworkImage(
                    imageUrl: recipeDetails.userDetails?.profilePicture ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipeDetails.userDetails?.username ?? 'Unknown Chef',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const Text(
                  "2 min ago", // We can use created_at if desired
                  style: TextStyle(color: Color(0xFF7D7D7D), fontSize: 13),
                ),
              ],
            ),
          ),
          Obx(() {
            final isLiked = controller.isLiked.value;
            return GestureDetector(
              onTap: controller.toggleLike,
              child: Row(
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : const Color(0xFF7D7D7D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${recipeDetails.totalLikes.value}',
                    style: const TextStyle(color: Color(0xFF7D7D7D)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStats(RecipeDetailsModel recipeDetails) {
    return Row(
      children: [
        const Icon(Icons.room_service_outlined, color: Colors.grey, size: 20),
        const SizedBox(width: 5),
        Text(
          '${recipeDetails.servings} Servings',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 20),
        const Icon(Icons.access_time, color: Colors.grey, size: 20),
        const SizedBox(width: 5),
        Text(
          '${recipeDetails.preparationTime} Minutes',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RecipeDetailsModel recipeDetails) {
    final hasVideo =
        recipeDetails.isVideo ||
        (recipeDetails.media?.endsWith('.mp4') ?? false);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: controller.startCooking,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF9EDC3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Learn Recipe Step-by-Step",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasVideo) ...[
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.black,
                        child: Obx(() {
                          if (controller.isVideoInitialized.value &&
                              controller.chewieController != null) {
                            return Chewie(
                              controller: controller.chewieController!,
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                        }),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                ),
                barrierColor: Colors.black87,
              );
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIngredientList(RecipeDetailsModel recipeDetails) {
    return Column(
      children: recipeDetails.ingredients
          .map<Widget>(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ingredient.amount} ${ingredient.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.grey),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFrostingList(RecipeDetailsModel recipeDetails) {
    return Column(
      children: recipeDetails.frosting
          .map<Widget>(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ingredient.amount} ${ingredient.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.grey),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStepsList(RecipeDetailsModel recipeDetails) {
    return Column(
      children: recipeDetails.steps
          .map<Widget>(
            (step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${step.step}: ${step.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(step.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.grey),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
