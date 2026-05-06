import 'package:get/get.dart';
import 'post_model.dart';
import 'repository/post_repository.dart';
import 'interaction_action_model.dart';
import '../../auth/data/auth_service.dart';
import '../../saved/controller/saved_controller.dart';

class HomeService extends GetxService {
  static HomeService get to => Get.find();

  final PostRepository _repository = PostRepository();

  final feedPosts = <Post>[].obs;
  final stories = <Chef>[].obs;
  final explorePosts = <Post>[].obs;

  final feedStatus = RxStatus.loading().obs;
  final storiesStatus = RxStatus.loading().obs;
  final exploreStatus = RxStatus.loading().obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    fetchStories();
    fetchFeed();
    fetchExplore();
  }

  Future<void> fetchFeed() async {
    feedStatus.value = RxStatus.loading();
    try {
      final posts = await _repository.getAllPosts();

      final currentEmail = AuthService.to.currentUser.value?.email ?? '';
      final currentUsername = AuthService.to.currentUser.value?.username ?? '';
      final currentId = AuthService.to.currentUser.value?.id.toString() ?? '';

      final updatedPosts = posts.map((post) {
        final isLiked =
            post.likesList?.any(
              (like) =>
                  like.user == currentEmail ||
                  like.user == currentUsername ||
                  like.user == currentId,
            ) ??
            false;
        final isPinned =
            post.pinsList?.any(
              (pin) =>
                  pin.user == currentEmail ||
                  pin.user == currentUsername ||
                  pin.user == currentId,
            ) ??
            false;
        final isSaved =
            post.savesList?.any(
              (save) =>
                  save.user == currentEmail ||
                  save.user == currentUsername ||
                  save.user == currentId,
            ) ??
            false;
        return post.copyWith(
          isLiked: isLiked || post.isLiked,
          isPinned: isPinned || post.isPinned,
          isSaved: isSaved || post.isSaved,
        );
      }).toList();

      feedPosts.assignAll(updatedPosts);
      feedStatus.value = posts.isEmpty ? RxStatus.empty() : RxStatus.success();
    } catch (e) {
      feedStatus.value = RxStatus.error(e.toString());
    }
  }

  Future<void> refreshFeedBackground() async {
    try {
      final posts = await _repository.getAllPosts();

      final currentEmail = AuthService.to.currentUser.value?.email ?? '';
      final currentUsername = AuthService.to.currentUser.value?.username ?? '';
      final currentId = AuthService.to.currentUser.value?.id.toString() ?? '';

      final updatedPosts = posts.map((post) {
        final isLiked =
            post.likesList?.any(
              (like) =>
                  like.user == currentEmail ||
                  like.user == currentUsername ||
                  like.user == currentId,
            ) ??
            false;
        final isPinned =
            post.pinsList?.any(
              (pin) =>
                  pin.user == currentEmail ||
                  pin.user == currentUsername ||
                  pin.user == currentId,
            ) ??
            false;
        final isSaved =
            post.savesList?.any(
              (save) =>
                  save.user == currentEmail ||
                  save.user == currentUsername ||
                  save.user == currentId,
            ) ??
            false;
        return post.copyWith(
          isLiked: isLiked || post.isLiked,
          isPinned: isPinned || post.isPinned,
          isSaved: isSaved || post.isSaved,
        );
      }).toList();

      feedPosts.assignAll(updatedPosts);
      if (feedStatus.value.isError ||
          feedStatus.value.isEmpty ||
          feedStatus.value.isLoading) {
        feedStatus.value = posts.isEmpty
            ? RxStatus.empty()
            : RxStatus.success();
      }
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }

  Future<void> fetchStories() async {
    storiesStatus.value = RxStatus.loading();
    try {
      final data = await _repository.getStories();
      stories.assignAll(data);
      storiesStatus.value = data.isEmpty
          ? RxStatus.empty()
          : RxStatus.success();
    } catch (e) {
      storiesStatus.value = RxStatus.error(e.toString());
    }
  }

  Future<void> fetchExplore() async {
    exploreStatus.value = RxStatus.loading();
    try {
      final data = await _repository.getExplorePosts();
      explorePosts.assignAll(data);
      exploreStatus.value = data.isEmpty
          ? RxStatus.empty()
          : RxStatus.success();
    } catch (e) {
      exploreStatus.value = RxStatus.error(e.toString());
    }
  }

  Future<void> likeFeedPost(String postId) async {
    final index = feedPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final currentPost = feedPosts[index];
    final bool updatedIsLiked = !currentPost.isLiked;
    int currentLikes = int.tryParse(currentPost.likes) ?? 0;
    int newLikes = updatedIsLiked ? currentLikes + 1 : currentLikes - 1;
    if (newLikes < 0) newLikes = 0;

    // Optimistic UI Update
    feedPosts[index] = currentPost.copyWith(
      isLiked: updatedIsLiked,
      likes: newLikes.toString(),
    );
    feedPosts.refresh();

    try {
      final success = await _repository.likePost(postId);
      if (!success) throw Exception("API returned false");
    } catch (e) {
      // Revert if API fails
      feedPosts[index] = currentPost.copyWith(
        isLiked: !updatedIsLiked,
        likes: currentLikes.toString(),
      );
      feedPosts.refresh();
      Get.snackbar("Error", "Failed to like post.");
    }
  }

  Future<void> pinFeedPost(String postId) async {
    final index = feedPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final currentPost = feedPosts[index];
    final bool updatedIsPinned = !currentPost.isPinned;
    // Optimistic UI Update
    feedPosts[index] = currentPost.copyWith(isPinned: updatedIsPinned);
    feedPosts.refresh();

    try {
      final success = await _repository.pinPost(postId);
      if (!success) throw Exception("API returned false");
    } catch (e) {
      // Revert if API fails
      feedPosts[index] = currentPost.copyWith(isPinned: !updatedIsPinned);
      feedPosts.refresh();
      Get.snackbar("Error", "Failed to pin post.");
    }
  }

  Future<void> saveFeedPost(String postId) async {
    final index = feedPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final currentPost = feedPosts[index];
    final bool updatedIsSaved = !currentPost.isSaved;
    // Optimistic UI Update
    feedPosts[index] = currentPost.copyWith(isSaved: updatedIsSaved);
    feedPosts.refresh();

    try {
      final success = await _repository.savePost(postId);
      if (!success) throw Exception("API returned false");

      if (Get.isRegistered<SavedController>())
        SavedController.to.fetchSavedItems();
    } catch (e) {
      // Revert if API fails
      feedPosts[index] = currentPost.copyWith(isSaved: !updatedIsSaved);
      feedPosts.refresh();
      Get.snackbar("Error", "Failed to save post.");
    }
  }

  Future<void> deleteFeedPost(String postId) async {
    final int index = feedPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    try {
      final success = await _repository.deletePost(postId);
      if (success) {
        feedPosts.removeAt(index);
        Get.snackbar('Success', 'Post deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete post. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post. Please try again.');
    }
  }

  Future<bool> submitPostComment(String postId, String text) async {
    final index = feedPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return false;

    try {
      final newComment = await _repository.addComment(postId, text);
      if (newComment != null) {
        final post = feedPosts[index];

        final updatedList = List<InteractionActionModel>.from(
          post.commentsList ?? [],
        )..add(newComment);
        final currentCount = int.tryParse(post.commentsCount) ?? 0;

        feedPosts[index] = post.copyWith(
          commentsList: updatedList,
          commentsCount: (currentCount + 1).toString(),
        );
        Get.snackbar('Success', 'Comment added successfully');
        return true;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add comment.");
    }
    return false;
  }

  void updateFeedPostLocally(Post updatedPost) {
    final int index = feedPosts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      feedPosts[index] = updatedPost;
      feedPosts.refresh(); // Trigger Obx refresh
    }
  }

  /// Removes all posts from a specific user (used after blocking)
  void removePostsByUser(int userId) {
    feedPosts.removeWhere((post) => post.userDetails?.id == userId);
    feedPosts.refresh();
  }
}
