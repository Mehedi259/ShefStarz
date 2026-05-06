import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/image/app_image.dart';
import '../../../core/widgets/custom_icon_button/custom_icon_button.dart';
import '../controller/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowersView extends StatelessWidget {
  const FollowersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Followers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(
          onTap: () => Get.back(),
          iconColor: AppColors.iconColor,
          backgroundColor: AppColors.paleYellow,
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingLists.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        final followers = controller.followersList;

        if (followers.isEmpty) {
          return const Center(child: Text("No followers yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        (user.profilePicture != null &&
                            user.profilePicture!.isNotEmpty)
                        ? (user.profilePicture!.startsWith('assets/')
                                  ? AssetImage(user.profilePicture!)
                                  : CachedNetworkImageProvider(
                                      user.profilePicture!,
                                    ))
                              as ImageProvider
                        : AssetImage(MyAppImage.girlcooking) as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'Unknown' : user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Text(
                            user.bio!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Assuming "Followers" might not necessarily be "Following" yet
                  // Check if we are following this user
                  Obx(() {
                    final isFollowingUser = controller.followingList.any(
                      (u) => u.id == user.id,
                    );

                    return ElevatedButton(
                      onPressed: () {
                        // Optimistic UI update
                        if (isFollowingUser) {
                          controller.followingList.removeWhere(
                            (u) => u.id == user.id,
                          );
                        } else {
                          controller.followingList.add(user);
                        }
                        controller.toggleFollow(user.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowingUser
                            ? Colors.grey.shade200
                            : AppColors.paleYellow,
                        foregroundColor: isFollowingUser
                            ? Colors.redAccent
                            : AppColors.iconColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(
                        isFollowingUser ? "Unfollow" : "Follow back",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
