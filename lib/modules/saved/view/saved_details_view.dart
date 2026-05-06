import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/saved_controller.dart';
import '../../../core/widgets/feed_post_card.dart';
import '../../home/data/home_service.dart';
import '../../home/data/post_model.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/widgets/wide_recipe_card.dart';
import '../../../routes/app_pages.dart';

class SavedDetailsView extends GetView<SavedController> {
  const SavedDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String collectionId = Get.arguments?['id'] ?? '';
    final String collectionTitle =
        Get.arguments?['title'] ?? 'My Saved recipes';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          collectionTitle,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
            size: 20,
          ),
        ),
      ),
      body: Obx(() {
        final controller = Get.find<SavedController>();
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());

        List<Post> displayPosts = [];

        final collection = controller.customCollections.firstWhereOrNull(
          (c) => c.id == collectionId,
        );
        if (collection != null) {
          displayPosts = controller.savedItems
              .where((post) => collection.itemIds.contains(post.id.toString()))
              .toList();
        }

        if (displayPosts.isEmpty)
          return const Center(
            child: Text("No saved items in this collection."),
          );

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: displayPosts.length,
          itemBuilder: (context, index) {
            final post = displayPosts[index];

            // Render Recipe Card
            if (post.postType == 'recipe') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: WideRecipeCard(
                  title: post.title,
                  chefName: post.chefName,
                  time: post
                      .timeAgo, // or parse preparationTime if you added it to Post model
                  servings: '1', // default or parse if available
                  rating: '4.5',
                  image:
                      post.userDetails?.profilePicture ??
                      'assets/images/placeholder.jpg',
                  recipesImg: post.image.isNotEmpty
                      ? post.image
                      : 'assets/images/placeholder.jpg',
                  isSaved: true.obs,
                  onTap: () => Get.toNamed(
                    Routes.RECIPE_DETAIL,
                    arguments: {'id': post.id},
                  ),
                  recipeId: post.id.toString(),
                  chefId: post.userDetails?.id.toString() ?? '',
                  onSaveTap: () => controller.confirmAndUnsave(post),
                  onDeleteTap: null, // No delete from saved page
                ),
              );
            }

            // Render Regular Post Card
            return FeedPostCard(
              chefName: post.chefName,
              timeAgo: post.timeAgo,
              title: post.title,
              description: post.description,
              likes: post.likes,
              comments: post.commentsCount,
              image: post.image,
              postType: post.postType,
              isSaved: true,
              isLiked: post.isLiked,
              isPinned: post.isPinned,
              onSaveTap: () => controller.confirmAndUnsave(post),
              onShareTap: () {
                Share.share(
                  'Check out this awesome post on Chefstarz: https://chefstarz.com/post/${post.id}',
                );
              },
              onLikeTap: () => HomeService.to.likeFeedPost(post.id),
              onPinTap: () => HomeService.to.pinFeedPost(post.id),
            );
          },
        );
      }),
    );
  }
}
