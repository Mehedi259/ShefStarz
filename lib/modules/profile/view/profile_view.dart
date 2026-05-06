import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
// import '../../../core/widgets/app_image.dart';
import '../../../core/image/app_image.dart';
import '../../../core/widgets/my_recipe_card/my_recipe_card.dart';
import '../../../routes/app_pages.dart';
import '../../auth/data/auth_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../../core/widgets/wide_recipe_card.dart';
import '../controller/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.SETTINGS),
            icon: Icon(Icons.menu, color: theme.iconTheme.color, size: 28),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Obx(() {
                  final profileController = Get.find<ProfileController>();
                  final user =
                      profileController.currentUser.value ??
                      AuthService.to.currentUser.value;

                  if (profileController.isLoadingProfile.value &&
                      user == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    // gradient: AppColors.primaryGradient,
                                  ),
                                  child: ClipOval(
                                    child:
                                        user?.profilePicture?.isNotEmpty == true
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                '${user!.profilePicture!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const CircleAvatar(
                                                      radius: 50,
                                                      backgroundColor:
                                                          Colors.grey,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    ),
                                          )
                                        : const CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.grey,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          ),
                                  ),
                                  // AppImage(url: user?.avatar ?? MyAppImage.girlcooking, width: 80, height: 80, isCircular: true,),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,

                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      // color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      MyAppImage.profilesiteicon,
                                      height: 47,
                                      width: 47,
                                      fit: BoxFit.cover,
                                    ),
                                    // Icon(Icons.star, color: Colors.white, size: 12,),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user?.name ?? "Guest Chef",
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ShaderMask(
                                        shaderCallback: (bounds) => AppColors
                                            .primaryGradient
                                            .createShader(bounds),
                                        child: const Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    user != null
                                        ? "@${user.name.replaceAll(' ', '').toLowerCase()}"
                                        : "@guest",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (user?.location == null ||
                                      user!.location!.isEmpty)
                                    const SizedBox.shrink()
                                  else ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.location!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          user?.bio ??
                              "🌈 Making colorful recipes | 🍪 Cookie lover | 🎨 Food artist",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: theme.dividerColor),
                      // Stats
                      Obx(() {
                        final user =
                            profileController.currentUser.value ??
                            AuthService.to.currentUser.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ProfileStat(
                              label: "Posts",
                              value: profileController.myPosts.length
                                  .toString(),
                            ),
                            _ProfileStat(
                              label: "Recipes",
                              value: profileController.myRecipes.length
                                  .toString(),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(Routes.FOLLOWERS),
                              child: _ProfileStat(
                                label: "Followers",
                                value: (user?.followerCount ?? 0).toString(),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(Routes.FOLLOWING),
                              child: _ProfileStat(
                                label: "Following",
                                value: (user?.followingCount ?? 0).toString(),
                              ),
                            ),
                          ],
                        );
                      }),
                      Divider(color: theme.dividerColor),
                      // Tab Bar
                      TabBar(
                        indicatorColor: const Color(0xFFFF8A1F),
                        labelColor: const Color(0xFFFF8A1F),
                        unselectedLabelColor: Colors.grey,
                        dividerColor: Colors.transparent,
                        tabs: [
                          const Tab(text: "Posts", icon: Icon(Icons.grid_view)),
                          const Tab(
                            text: "Recipes",
                            icon: Icon(Icons.restaurant),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ];
          },
          body: TabBarView(
            children: [_buildPostsGrid(theme), _buildRecipesList(theme)],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid(ThemeData theme) {
    DashboardController controller = Get.find<DashboardController>();
    return Obx(() {
      final profileController = Get.find<ProfileController>();
      if (profileController.isLoadingMyPosts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final posts = profileController.myPosts;
      if (posts.isEmpty) {
        return const Center(child: Text("No posts yet"));
      }
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns for details
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8, // Taller for text
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return MyRecipeCard(
            post: post,
            index: index,
            onTap: () {
              // print("Clicked on ${post.title}");
              // Get.toNamed('/details', arguments: post);
            },
            img: post.image.isNotEmpty
                ? post.image
                : (index < controller.images.length
                      ? controller.images[index]
                      : ""),
          );
        },
      );
    });
  }

  Widget _buildRecipesList(ThemeData theme) {
    return Obx(() {
      final profileController = Get.find<ProfileController>();
      if (profileController.isLoadingMyRecipes.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (profileController.myRecipes.isEmpty) {
        return const Center(child: Text("No recipes uploaded yet."));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: profileController.myRecipes.length,
        itemBuilder: (context, index) {
          final recipe = profileController.myRecipes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: WideRecipeCard(
              title: recipe.title,
              // FIX 1: Explicitly use the current user's name since these are their own recipes
              chefName:
                  profileController.currentUser.value?.username ??
                  'Unknown Chef',
              // FIX 2: Ensure time is properly passed and formatted
              time: recipe.time.isNotEmpty ? recipe.time : '-',
              servings: recipe.servings.toString(),
              rating: '4.5',
              image:
                  profileController.currentUser.value?.profilePicture ??
                  'assets/images/placeholder.jpg',
              recipesImg: recipe.image.isNotEmpty
                  ? recipe.image
                  : 'assets/images/placeholder.jpg',
              // Safely pass the ID for the detail page routing
              onTap: () => Get.toNamed(
                Routes.RECIPE_DETAIL,
                arguments: {'id': recipe.id},
              ),
              recipeId: recipe.id.toString(),
              chefId: profileController.currentUser.value?.id.toString() ?? 
                      AuthService.to.currentUser.value?.id.toString() ?? '',
              // FIX 3: Remove Save and Delete actions from the profile screen
              onSaveTap: null,
              onDeleteTap: null,
            ),
          );
        },
      );
    });
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
      ],
    );
  }
}
