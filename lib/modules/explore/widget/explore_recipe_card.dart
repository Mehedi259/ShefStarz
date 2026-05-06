import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../recipes/data/recipe_details_model.dart';
import '../../../core/colors/app_colors.dart';
import 'package:get/get.dart';

class ExploreRecipeCard extends StatelessWidget {
  final RecipeDetailsModel recipe;
  final int index;
  final VoidCallback? onTap;

  const ExploreRecipeCard({
    super.key,
    required this.recipe,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Only use the API media URL. If it's null/empty, we let the safe fallback handle it.
    final displayImg = recipe.media?.isNotEmpty == true ? recipe.media! : '';

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
                    if (displayImg.isEmpty)
                      Container(
                        color: theme.brightness == Brightness.light
                            ? Colors.orange.shade100
                            : Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                      )
                    else if (displayImg.toLowerCase().endsWith('.mp4') ||
                        displayImg.toLowerCase().endsWith('.avi') ||
                        displayImg.toLowerCase().endsWith('.mov'))
                      Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: displayImg,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print(
                            "Image Load Error: $error for URL: $displayImg",
                          );
                          return Container(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),

                    if (displayImg.isNotEmpty &&
                        (displayImg.toLowerCase().endsWith('.mp4') ||
                            displayImg.toLowerCase().endsWith('.avi') ||
                            displayImg.toLowerCase().endsWith('.mov')))
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white70,
                          size: 24,
                        ),
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
                      recipe.title.isNotEmpty ? recipe.title : "Delicious Dish",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      recipe.description.isNotEmpty
                          ? recipe.description
                          : "Tasty & healthy",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Obx(
                      () => Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.totalLikes.value.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
