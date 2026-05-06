import 'package:get/get.dart';
import '../data/post_model.dart';
import '../data/repository/post_repository.dart';

class PostDetailController extends GetxController {
  final PostRepository _postRepository = PostRepository();

  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final Rxn<Post> post = Rxn<Post>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) {
      fetchPostDetails(args);
    }
  }

  Future<void> fetchPostDetails(String postId) async {
    isLoading.value = true;
    isError.value = false;
    post.value = null;

    try {
      final fetchedPost = await _postRepository.getPostDetails(postId);
      if (fetchedPost != null) {
        post.value = fetchedPost;
      } else {
        isError.value = true;
        Get.back();
        Get.snackbar(
          'Unavailable',
          'This content is no longer available or the user is blocked.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
