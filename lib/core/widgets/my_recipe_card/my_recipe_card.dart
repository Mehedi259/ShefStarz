import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../modules/dashboard/controller/dashboard_controller.dart';
import '../../../modules/home/data/post_model.dart';
import '../../colors/app_colors.dart';
// import '../app_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyRecipeCard extends StatelessWidget {
  final Post post;
  final String img;
  final int index;
  final VoidCallback? onTap;

  const MyRecipeCard({
    super.key,
    required this.post,
    required this.index,
    this.onTap,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    // DashboardController controller = Get.find<DashboardController>();
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? AppColors.paleYellow
              : theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ensure AppImage is defined in your project
                    // AppImage(url: post.image, fit: BoxFit.cover),
                    Builder(
                      builder: (context) {
                        final String mediaUrl = img.isNotEmpty
                            ? img
                            : post.image;
                        final bool isVideo =
                            mediaUrl.toLowerCase().endsWith('.mp4') ||
                            mediaUrl.toLowerCase().endsWith('.avi') ||
                            mediaUrl.toLowerCase().endsWith('.mov') ||
                            post.postType == 'video';

                        if (mediaUrl.isEmpty) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        }

                        if (isVideo) {
                          return Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        } else {
                          return CachedNetworkImage(
                            imageUrl: mediaUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      post.title.isNotEmpty ? post.title : "Delicious Dish",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      post.description.isNotEmpty
                          ? post.description
                          : "Tasty & healthy",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          post.likes.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
