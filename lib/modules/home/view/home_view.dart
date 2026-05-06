import 'package:chef_starz/core/image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/custom_dialogs.dart';
import '../../../core/widgets/feed_post_card.dart';
import '../../../core/widgets/comments_sheet.dart';
import '../../../core/widgets/pinned_post_card.dart';
import '../../../core/widgets/save_collection_bottom_sheet.dart';
import '../../../core/widgets/safety_banner.dart';
import '../../../core/widgets/safety_reminder_dialog.dart';
import '../../../core/widgets/custom_dialogs.dart';
import '../../trust_and_safety/controller/trust_and_safety_controller.dart';
import '../controller/home_controller.dart';
import '../data/home_service.dart';
import '../../../routes/app_pages.dart';
import '../../auth/data/auth_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../../data/models/user_model.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Image.asset(MyAppImage.appLogo),
        backgroundColor: Colors.transparent,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.gradientEnd1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(5),
              child: SvgPicture.asset(MyAppImage.bell),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => HomeService.to.fetchInitialData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => controller.isSafetyBannerVisible.value
                      ? SafetyBanner(
                          onClose: () =>
                              controller.isSafetyBannerVisible.value = false,
                        )
                      : const SizedBox.shrink(),
                ),
                // Search Bar
                // CustomSearchField(hintText: 'Search Recipes...', onTap: () => Get.toNamed(Routes.SEARCH),),
                // const SizedBox(height: 20),
                // Active Chefs (Stories)
                // Obx(() {
                //   final status = HomeService.to.storiesStatus.value;
                //   if (status.isLoading) {
                //     return const SizedBox(
                //       height: 90,
                //       child: Center(child: CircularProgressIndicator()),
                //     );
                //   }
                //   return SizedBox(
                //     height: 95,
                //     child: ListView.builder(
                //       scrollDirection: Axis.horizontal,
                //       itemCount: controller.images1.length,
                //       // HomeService.to.stories.length,
                //       itemBuilder: (context, index) {
                //         final chef = HomeService.to.stories[index];
                //         return Padding(
                //           padding: const EdgeInsets.only(right: 15),
                //           child: Column(
                //             children: [
                //               Container(
                //                 padding: const EdgeInsets.all(2),
                //                 decoration: const BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   gradient: AppColors.primaryGradient,
                //                 ),
                //                 child: Image.asset(controller.images1[index]),
                //
                //
                //                 // AppImage(url: chef.image, width: 60, height: 60, isCircular: true,),
                //               ),
                //               const SizedBox(height: 5),
                //               Text(
                //                 chef.name,
                //                 style: theme.textTheme.bodyMedium?.copyWith(
                //                   fontSize: 10,
                //                 ),
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             ],
                //           ),
                //         );
                //       },
                //     ),
                //   );
                // }),

                // const SizedBox(height: 10),

                // Pinned for today
                Obx(() {
                  final pinned = controller.pinnedPosts;
                  if (pinned.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pinned.length,
                      itemBuilder: (context, index) {
                        final post = pinned[index];
                        return PinnedPostCard(
                          post: post,
                          onTap: () {
                            if (post.postType == 'recipe') {
                              Get.toNamed(
                                '/recipe-detail',
                                arguments: {'id': post.id},
                              );
                            } else {
                              Get.toNamed('/post-details', arguments: post.id);
                            }
                          },
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Feed Posts
                Obx(() {
                  final status = HomeService.to.feedStatus.value;
                  if (status.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (status.isError) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            status.errorMessage ?? "Error",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => HomeService.to.fetchFeed(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (status.isEmpty || HomeService.to.feedPosts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "No posts available. Be the first to share something!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  // Capture the controller instance explicitly
                  final homeCtrl = controller;

                  return ListView.builder(
                    shrinkWrap: true, // Needed if inside another ScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Use parent's scroll
                    itemCount: HomeService.to.feedPosts.length,
                    itemBuilder: (context, index) {
                      final post = HomeService.to.feedPosts[index];

                      final currentUser = AuthService.to.currentUser.value;
                      final isOwnPost =
                          currentUser != null &&
                          post.userDetails?.id.toString() ==
                              currentUser.id.toString();

                      ProfileController? profileCtrl;
                      try {
                        profileCtrl = Get.find<ProfileController>();
                      } catch (e) {
                        profileCtrl = Get.put(ProfileController());
                      }
                      final targetId = post.userDetails?.id.toString() ?? '';

                      return Obx(() {
                        final isFollowing = profileCtrl!.followingList.any(
                          (u) => u.id == targetId,
                        );

                        return FeedPostCard(
                          isLiked: post.isLiked,
                          isPinned: post.isPinned,
                          isSaved: post.isSaved,
                          onLikeTap: () => HomeService.to.likeFeedPost(post.id),
                          onPinTap: () => HomeService.to.pinFeedPost(post.id),
                          onSaveTap: () {
                            Get.bottomSheet(
                              SaveCollectionBottomSheet(
                                itemId: post.id.toString(),
                                onSaveToCollection: (collectionId) {
                                  HomeService.to.saveFeedPost(post.id);
                                },
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          onShareTap: () {
                            Share.share(
                              'Check out this awesome post on Chefstarz: https://chefstarz.com/post/${post.id}',
                            );
                          },
                          onProfileTap: () {
                            // Safely get IDs
                            final postUserId =
                                post.userDetails?.id.toString() ?? '';
                            final currentUserId =
                                AuthService.to.currentUser.value?.id
                                    .toString() ??
                                '';

                            if (postUserId.isEmpty) {
                              print("Error: Post User ID is missing");
                              return; // Prevent navigation if ID is completely unknown
                            }

                            if (postUserId == currentUserId) {
                              // Navigate to own profile tab via DashboardController
                              try {
                                final dashboardCtrl =
                                    Get.find<DashboardController>();
                                dashboardCtrl.setTabIndex(3);
                              } catch (e) {
                                print('Dashboard controller not found');
                              }
                            } else {
                              // Navigate to other profile safely
                              Get.toNamed(
                                '/other-profile',
                                arguments: {
                                  'userId': int.tryParse(postUserId) ?? 0,
                                },
                              );
                            }
                          },
                          isOwnPost: isOwnPost,
                          isFollowing: isFollowing,
                          onDeleteTap: () {
                            CustomDialogs.showActionDialog(
                              title: "Delete Post?",
                              subtitle: "Are you sure you want to delete this post? This action cannot be undone.",
                              confirmText: "Delete",
                              isDestructive: true,
                              icon: Icons.delete_outline,
                              onConfirm: () {
                                Get.back();
                                HomeService.to.deleteFeedPost(post.id);
                              },
                            );
                          },
                          onFollowTap: () {
                            if (targetId.isNotEmpty) {
                              if (isFollowing) {
                                profileCtrl?.followingList.removeWhere(
                                  (u) => u.id == targetId,
                                );
                              } else {
                                if (post.userDetails != null) {
                                  profileCtrl?.followingList.add(
                                    UserModel(
                                      id: targetId,
                                      email: '',
                                      username: post.userDetails!.username,
                                      profilePicture:
                                          post.userDetails!.profilePicture,
                                    ),
                                  );
                                }
                              }
                              profileCtrl?.toggleFollow(targetId);

                              // Snackbars will be handled in toggleFollow locally or we can keep it here but we want immediate reactiveness.
                            }
                          },
                          onReportTap: () {
                            CustomDialogs.showReportDialog(
                              onReport: (reason) {
                                final tsCtrl = Get.find<TrustAndSafetyController>();
                                final intPostId = int.tryParse(post.id) ?? -1;
                                if (intPostId != -1) {
                                  tsCtrl.report(
                                    targetId: intPostId,
                                    targetType: 'post',
                                    reason: reason,
                                  );
                                }
                              },
                            );
                          },
                          onBlockTap: () {
                            if (post.userDetails != null) {
                              final tsCtrl = Get.find<TrustAndSafetyController>();
                              tsCtrl.blockUser(post.userDetails!.id);
                            }
                          },
                          chefName: post.chefName,
                          timeAgo: post.timeAgo,
                          title: post.title,
                          description: post.description,
                          likes: post.likes,
                          comments: post.commentsCount,
                          image: post.image,
                          postType: post.postType,
                          profilePicture: post.userDetails?.profilePicture,
                          onCommentTap: () async {
                            final proceed = await Get.dialog<bool>(
                              const SafetyReminderDialog(),
                            );

                            if (proceed != true) return;

                            Get.bottomSheet(
                              CommentsSheet(controller: homeCtrl, post: post),
                              isScrollControlled: true,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                            );
                          },
                        );
                      });
                    },
                  );

                  // return Column(
                  //   children: HomeService.to.feedPosts.map((Post post) {
                  //     return FeedPostCard(
                  //       favoriteClick: controller.favoriteIconChan,
                  //       loveIconColors:controller.favoriteIcon.value?AppColors.gradientEnd:AppColors.textSecondary,
                  //       chefName: post.chefName,
                  //       timeAgo: post.timeAgo,
                  //       title: post.title,
                  //       description: post.description,
                  //       likes: post.likes,
                  //       comments: post.commentsCount,
                  //       image: controller.images[index]   //post.image,
                  //       onCommentTap: () {
                  //         Get.bottomSheet(
                  //           const CommentsSheet(),
                  //           isScrollControlled: true,
                  //           backgroundColor: theme.scaffoldBackgroundColor,
                  //           shape: const RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.vertical(
                  //               top: Radius.circular(20),
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   }).toList(),
                  // );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
