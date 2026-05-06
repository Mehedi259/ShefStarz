import 'package:get/get.dart';
import '../../../core/image/app_image.dart';
import '../../../data/services/api_service.dart';
import '../data/home_service.dart';
import '../data/post_model.dart';
import '../../recipes/data/recipe_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());

  final count = 0.obs;
  RxBool favoriteIcon = false.obs;
  void favoriteIconChan() {
    favoriteIcon.value = !favoriteIcon.value;
  }

  final users = <Map<String, dynamic>>[].obs;

  List<Post> get pinnedPosts {
    // Get pinned posts
    final posts = HomeService.to.feedPosts.where((p) => p.isPinned).toList();

    // Get pinned recipes and convert them to Post format for the UI
    if (Get.isRegistered<RecipeService>()) {
      final pinnedRecipes = RecipeService.to.recipes
          .where((r) => r.isPinned.value)
          .map(
            (r) => Post(
              id: r.id.toString(),
              title: r.title,
              description: r.description,
              image: r.media ?? '',
              chefName: r.userDetails?.username ?? 'Unknown',
              timeAgo: r.createdAt,
              likes: r.totalLikes.value.toString(),
              commentsCount: r.totalComments.value.toString(),
              isPinned: true,
              postType: 'recipe', // crucial flag
            ),
          )
          .toList();
      posts.addAll(pinnedRecipes);
    }
    return posts;
  }

  final isSubmittingComment = false.obs;
  var isSafetyBannerVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDummyData();
  }

  Future<void> fetchDummyData() async {
    final data = await _apiService.getDummyData();
    users.assignAll(data);
  }

  void increment() => count.value++;

  final List<String> images = [
    MyAppImage.cake,
    MyAppImage.recepi2,
    MyAppImage.recepi1,
    MyAppImage.search1,
    MyAppImage.search2,
    MyAppImage.search3,
    MyAppImage.profile1,
    MyAppImage.recepi1,
    MyAppImage.search1,
    MyAppImage.search2,
    MyAppImage.search3,
    MyAppImage.profile1,
  ];
  final List<String> images1 = [
    MyAppImage.man1,
    MyAppImage.man2,
    MyAppImage.man3,
    MyAppImage.man4,
    MyAppImage.man2,
    MyAppImage.man3,
    MyAppImage.man4,
  ];

  Future<void> submitComment(String postId, String text) async {
    if (text.isEmpty) return;

    isSubmittingComment.value = true;
    final success = await HomeService.to.submitPostComment(postId, text);
    isSubmittingComment.value = false;

    if (success) {
      // Input clearing handled locally by sheet
    }
  }
}
