import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../colors/app_colors.dart';

import '../../core/image/app_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../../core/widgets/video_player_screen.dart';
import '../../../core/widgets/auto_play_video_widget.dart';
import 'custom_dialogs.dart';

class FeedPostCard extends StatelessWidget {
  final String chefName;
  final String timeAgo;
  final String title;
  final String description;
  final String likes;
  final String comments;
  final String image;
  final bool isLiked;
  final bool isPinned;
  final bool isSaved;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onPinTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;
  final bool isOwnPost;
  final bool isFollowing;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onBlockTap;
  final String? postType;
  final String? profilePicture;

  const FeedPostCard({
    super.key,
    required this.chefName,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
    required this.image,
    this.isLiked = false,
    this.isPinned = false,
    this.isSaved = false,
    this.onCommentTap,
    this.onLikeTap,
    this.onPinTap,
    this.onSaveTap,
    this.onShareTap,
    this.isOwnPost = false,
    this.isFollowing = false,
    this.onDeleteTap,
    this.onFollowTap,
    this.onProfileTap,
    this.onReportTap,
    this.onBlockTap,
    this.postType,
    this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String displayTime = timeAgo;
    try {
      final parsedDate = DateTime.parse(timeAgo);
      displayTime = DateFormat.yMMMd().add_jm().format(parsedDate.toLocal());
    } catch (_) {
      // Fallback
    }

    final isVideo =
        postType == 'video' ||
        image.toLowerCase().endsWith('.mp4') ||
        image.toLowerCase().endsWith('.avi') ||
        image.toLowerCase().endsWith('.mov');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: ClipOval(
                    child: profilePicture != null && profilePicture!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profilePicture!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                          )
                        : const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onProfileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chefName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          displayTime,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onPinTap,
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? AppColors.gradientEnd : Colors.grey,
                    size: 30,
                  ),
                ),
                if (onDeleteTap != null || onFollowTap != null || onReportTap != null || onBlockTap != null)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 28,
                    ),
                    color: theme.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (String result) {
                      if (result == 'delete' && onDeleteTap != null) {
                        onDeleteTap!();
                      } else if (result == 'follow' && onFollowTap != null) {
                        onFollowTap!();
                      } else if (result == 'report' && onReportTap != null) {
                        onReportTap!();
                      } else if (result == 'block' && onBlockTap != null) {
                        CustomDialogs.showActionDialog(
                          title: 'Block $chefName?',
                          subtitle: 'Are you sure? Their recipes and comments will be hidden from your feed.',
                          confirmText: 'Block',
                          isDestructive: true,
                          icon: Icons.block_outlined,
                          onConfirm: () {
                            Get.back();
                            onBlockTap!();
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          if (isOwnPost)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Post',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            if (onFollowTap != null)
                              PopupMenuItem<String>(
                                value: 'follow',
                                child: Row(
                                  children: [
                                    Icon(
                                      isFollowing
                                          ? Icons.person_remove_alt_1_outlined
                                          : Icons.person_add_alt_1_outlined,
                                      color: isFollowing
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isFollowing ? 'Unfollow' : 'Follow',
                                      style: TextStyle(
                                        color: isFollowing
                                            ? Colors.red
                                            : Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (onReportTap != null)
                              PopupMenuItem<String>(
                                value: 'report',
                                child: Row(
                                  children: const [
                                    Icon(Icons.flag_outlined, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text(
                                      'Report Post',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            if (onBlockTap != null)
                              PopupMenuItem<String>(
                                value: 'block',
                                child: Row(
                                  children: const [
                                    Icon(Icons.block_outlined, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Block User',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                  ),
              ],
            ),
          ),

          // Post Image/Video
          ClipRRect(
            borderRadius: BorderRadius.zero, // Keep it rectangular like images
            child: isVideo && image.isNotEmpty
                ? AutoPlayVideoWidget(
                    videoUrl: image,
                    height: 250,
                    onTap: () {
                      Get.to(() => VideoPlayerScreen(videoUrl: image));
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      if (isVideo && image.isNotEmpty) {
                        Get.to(() => VideoPlayerScreen(videoUrl: image));
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (image.startsWith('assets/'))
                          Image.asset(
                            image,
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              print("Asset Load Error for $image: $error");
                              return const Icon(Icons.error_outline);
                            },
                          )
                        else
                          CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              print("Image Load Error for $url: $error");
                              return const Icon(Icons.error_outline);
                            },
                          ),
                      ],
                    ),
                  ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: onLikeTap,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppColors.gradientEnd : Colors.grey,
                    size: 28,
                  ),
                ),
                // const SizedBox(width: 2),
                Text(likes, style: theme.textTheme.bodyMedium),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onCommentTap,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 5),
                      Text(comments, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: onShareTap,
                  icon: SvgPicture.asset(
                    MyAppImage.send,
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                ),

                const Spacer(),
                IconButton(
                  onPressed: onSaveTap,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.orange : Colors.grey,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
