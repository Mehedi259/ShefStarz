import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../colors/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'content_action_menu.dart';

class WideRecipeCard extends StatelessWidget {
  final String title;
  final String chefName;
  final String time;
  final String servings;
  final String image;
  final String recipesImg;
  final String rating;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onDeleteTap;
  final RxBool? isSaved;
  final String? recipeId;
  final String? chefId;

  const WideRecipeCard({
    super.key,
    required this.title,
    required this.chefName,
    required this.time,
    required this.servings,
    required this.image,
    required this.rating,
    this.onTap,
    this.onSaveTap,
    this.onDeleteTap,
    this.isSaved,
    required this.recipesImg,
    this.recipeId,
    this.chefId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 170,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? AppColors.paleYellow
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (onDeleteTap != null)
                              GestureDetector(
                                onTap: onDeleteTap,
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: ContentActionMenu(
                                contentId: recipeId ?? 'unknown_recipe',
                                targetUserId: chefId ?? 'unknown_chef',
                                targetUserName: chefName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "All-purpose flour, sugar, butter, eggs, and leavening agents such as baking powder, along with milk and vanilla extract...",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Stats
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.room_service_outlined,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            servings,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // AppImage(url: MyAppImage.girlcooking, width: 20, height: 20, isCircular: true,),
                        ClipOval(
                          child: image.isEmpty
                              ? const CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                )
                              : image.startsWith('assets/')
                              ? Image.asset(
                                  image,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const CircleAvatar(
                                        radius: 11,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: image,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                        radius: 11,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                ),
                        ),

                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chefName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Builder(
                    builder: (context) {
                      final bool isVideo =
                          recipesImg.toLowerCase().endsWith('.mp4') ||
                          recipesImg.toLowerCase().endsWith('.avi') ||
                          recipesImg.toLowerCase().endsWith('.mov');

                      if (recipesImg.isEmpty) {
                        return Container(
                          width: 120,
                          height: 155,
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
                          width: 120,
                          height: 155,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.black54],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "WATCH",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (recipesImg.startsWith('assets/')) {
                        return Image.asset(
                          recipesImg,
                          width: 120,
                          height: 155,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 155,
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
                      } else {
                        return CachedNetworkImage(
                          imageUrl: recipesImg,
                          width: 120,
                          height: 155,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            width: 120,
                            height: 155,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 155,
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onSaveTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: isSaved != null
                            ? Obx(
                                () => Icon(
                                  isSaved!.value
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isSaved!.value
                                      ? Colors.orange
                                      : Colors.white,
                                  size: 18,
                                ),
                              )
                            : const Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
