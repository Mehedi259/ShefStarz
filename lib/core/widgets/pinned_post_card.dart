import 'package:flutter/material.dart';
import '../../modules/home/data/post_model.dart';
import '../colors/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PinnedPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PinnedPostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? AppColors.paleYellow
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pinned for today",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      (post.image.toLowerCase().endsWith('.mp4') ||
                          post.image.toLowerCase().endsWith('.avi') ||
                          post.image.toLowerCase().endsWith('.mov'))
                      ? Container(
                          height: 60,
                          width: 80,
                          color: Colors.black87,
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: post.image,
                          height: 60,
                          width: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 60,
                            width: 80,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 60,
                            width: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likes,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.commentsCount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.push_pin, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
