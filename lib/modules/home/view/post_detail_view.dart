import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/post_detail_controller.dart';
import '../../../../core/widgets/feed_post_card.dart';

class PostDetailView extends GetView<PostDetailController> {
  const PostDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isError.value || controller.post.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Failed to load post details.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final args = Get.arguments;
                    if (args != null && args is String) {
                      controller.fetchPostDetails(args);
                    }
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final post = controller.post.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FeedPostCard(
            chefName: post.chefName,
            timeAgo: post.timeAgo,
            title: post.title,
            description: post.description,
            likes: post.likes,
            comments: post.commentsCount,
            image: post.image,
            postType: post.postType,
            isLiked: post.isLiked,
            isPinned: post.isPinned,
            isSaved: post.isSaved,
            onLikeTap: () {
              // Usually calls home_service but we are demonstrating details
            },
            onPinTap: () {},
            onSaveTap: () {},
            onCommentTap: () {
              // Similar to home Feed logic
            },
          ),
        );
      }),
    );
  }
}
