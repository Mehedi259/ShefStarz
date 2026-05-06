import 'dart:io';
import '../../../../core/image/app_image.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../post_model.dart';
import '../interaction_action_model.dart';

class PostRepository {
  final ApiClient _apiClient = ApiClient();

  Future<bool> likePost(String id) async {
    final response = await _apiClient.postRequest(ApiConfig.likePost(id), {});
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> pinPost(String id) async {
    final response = await _apiClient.postRequest(ApiConfig.pinPost(id), {});
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> savePost(String id) async {
    final response = await _apiClient.postRequest(ApiConfig.savePost(id), {});
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<InteractionActionModel?> addComment(String id, String text) async {
    final response = await _apiClient.postRequest(ApiConfig.addComment(id), {
      "comment": text,
    });

    if (response.statusCode == 201) {
      if (response.body is Map && response.body.containsKey('comment')) {
        return InteractionActionModel.fromJson(response.body['comment']);
      }
    }
    return null;
  }

  Future<Post?> getPostDetails(String id) async {
    final response = await _apiClient.getRequest(ApiConfig.getPostDetails(id));

    if (response.statusCode == 200) {
      // Decode the dynamic map into the Post
      final Map<String, dynamic> data = response.body;
      return Post.fromJson(data);
    }
    return null;
  }

  Future<bool> deletePost(String id) async {
    final response = await _apiClient.deleteRequest(ApiConfig.deletePost(id));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<Post?> updatePost(
    String id,
    String title,
    String description,
    File media,
  ) async {
    final Map<String, String> fields = {
      'title': title,
      'description': description,
    };

    final response = await _apiClient.putMultipartRequest(
      ApiConfig.updatePost(id),
      fields,
      file: media,
      fileKey: 'media',
    );

    if (response.statusCode == 200) {
      return Post.fromJson(response.body);
    }
    return null;
  }

  Future<Post?> partialUpdatePost(
    String id, {
    String? title,
    String? description,
    File? media,
  }) async {
    final Map<String, String> fields = {};
    if (title != null) fields['title'] = title;
    if (description != null) fields['description'] = description;

    final response = await _apiClient.patchMultipartRequest(
      ApiConfig.updatePost(id),
      fields,
      file: media,
      fileKey: 'media',
    );

    if (response.statusCode == 200) {
      return Post.fromJson(response.body);
    }
    return null;
  }

  Future<List<Post>> getAllPosts() async {
    final response = await _apiClient.getRequest(ApiConfig.getPostsList);

    if (response.statusCode == 200) {
      if (response.body is List) {
        return (response.body as List)
            .map((json) => Post.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<List<Post>> getSavedPosts() async {
    final response = await _apiClient.getRequest(
      "${ApiConfig.getPostsList}?saved=true",
    );
    if (response.statusCode == 200) {
      if (response.body is List) {
        return (response.body as List)
            .map((json) => Post.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<List<Chef>> getStories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(7, (index) {
      return Chef(
        id: 'chef_$index',
        name: "Chef ${index + 1}",
        image: MyAppImage.girlcooking,
      );
    });
  }

  Future<List<Post>> getExplorePosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(21, (index) {
      // 7 rows * 3 items = 21 items for grid
      return Post(
        id: 'explore_$index',
        chefName: "Chef ${index + 1}",
        timeAgo: "1h ago",
        title: "Recipe $index",
        description: "Description",
        likes: "100",
        commentsCount: "20",
        image: index % 3 == 0
            ? MyAppImage.cake
            : (index % 3 == 1 ? MyAppImage.recepi : MyAppImage.recepi2),
      );
    });
  }
}
