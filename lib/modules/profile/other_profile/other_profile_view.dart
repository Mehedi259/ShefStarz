import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../routes/app_pages.dart';
import '../../auth/data/auth_service.dart';
import 'other_profile_controller.dart';

class OtherProfileView extends GetView<OtherProfileController> {
  const OtherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() {
          final user = controller.userProfile.value;
          return Text(
            user?.username ?? '',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Obx(() {
                    final user = controller.userProfile.value;
                    if (user == null) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: (user.profilePicture ?? '').isEmpty
                                    ? const CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      )
                                    : user.profilePicture!.startsWith('assets/')
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage: AssetImage(
                                          user.profilePicture!,
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: user.profilePicture!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage:
                                                      imageProvider,
                                                ),
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.grey,
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                              ),
                              const SizedBox(width: 20),
                              // User Info and Follow Button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '@${user.username}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (user.location?.isNotEmpty == true) ...[
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            user.location!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Location not set",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 15),
                                    Obx(() {
                                      final isCurrentUser =
                                          controller.currentTargetUserId
                                              .toString() ==
                                          AuthService.to.currentUser.value?.id
                                              .toString();

                                      if (isCurrentUser) {
                                        return GestureDetector(
                                          onTap: () =>
                                              Get.toNamed(Routes.EDIT_PROFILE),
                                          child: Container(
                                            width: 140,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'Edit Profile',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      final isFollowing =
                                          controller.isFollowing.value;
                                      return GestureDetector(
                                        onTap: () => controller.toggleFollow(),
                                        child: Container(
                                          width: 140,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isFollowing
                                                ? null
                                                : const LinearGradient(
                                                    colors: [
                                                      Colors.purple,
                                                      Colors.orange,
                                                    ],
                                                  ),
                                            color: isFollowing
                                                ? Colors.grey.shade300
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            isFollowing ? 'Unfollow' : 'Follow',
                                            style: TextStyle(
                                              color: isFollowing
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bio
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            user.bio?.isNotEmpty == true
                                ? user.bio!
                                : 'No bio available',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ), // Match style to design
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Colors.grey.shade300,
                          indent: 20,
                          endIndent: 20,
                        ),
                        const SizedBox(height: 15),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              'Recipes',
                              '${controller.userRecipes.length}',
                            ),
                            GestureDetector(
                              onTap: () {
                                if (controller.followersList.isNotEmpty) {
                                  Get.toNamed(
                                    '/follow-network',
                                    arguments: {
                                      'type': 'Followers',
                                      'list': controller.followersList,
                                    },
                                  );
                                }
                              },
                              child: _buildStatColumn(
                                'Followers',
                                '${user.followerCount}',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (controller.followingList.isNotEmpty) {
                                  Get.toNamed(
                                    '/follow-network',
                                    arguments: {
                                      'type': 'Following',
                                      'list': controller.followingList,
                                    },
                                  );
                                }
                              },
                              child: _buildStatColumn(
                                'Following',
                                '${user.followingCount}',
                              ),
                            ),
                            _buildStatColumn(
                              'Posts',
                              '${controller.userPosts.length}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(
                          color: Colors.grey.shade300,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ],
                    );
                  }),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.orange,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.grid_view,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Posts',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Recipes',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [_buildPostsGrid(), _buildRecipesGrid()],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.userPosts.isEmpty) {
        return const Center(child: Text('No posts yet'));
      }
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.userPosts.length,
        itemBuilder: (context, index) {
          final post = controller.userPosts[index];
          final String imageUrl = post.image;
          final bool isVideo =
              imageUrl.toLowerCase().endsWith('.mp4') ||
              imageUrl.toLowerCase().endsWith('.avi') ||
              imageUrl.toLowerCase().endsWith('.mov') ||
              post.postType == 'video';

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (imageUrl.isEmpty || isVideo)
                  ? Colors.black87
                  : Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isEmpty)
                    const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    )
                  else if (isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.grey, size: 40),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            post.likes.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
        },
      );
    });
  }

  Widget _buildRecipesGrid() {
    return Obx(() {
      if (controller.isLoadingRecipes.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.userRecipes.isEmpty) {
        return const Center(child: Text('No recipes yet'));
      }
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.userRecipes.length,
        itemBuilder: (context, index) {
          final recipe = controller.userRecipes[index];
          final String imageUrl = recipe.image;
          final bool isVideo =
              imageUrl.toLowerCase().endsWith('.mp4') ||
              imageUrl.toLowerCase().endsWith('.avi') ||
              imageUrl.toLowerCase().endsWith('.mov');

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (imageUrl.isEmpty || isVideo)
                  ? Colors.black87
                  : Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isEmpty)
                    const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    )
                  else if (isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                  else if (imageUrl.startsWith('assets/'))
                    Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.grey, size: 40),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            recipe.likesCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
        },
      );
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
