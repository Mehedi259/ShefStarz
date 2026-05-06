import 'dart:io';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../recipes/data/recipe_model.dart';
import '../../../home/data/post_model.dart';

class UploadRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Post?> uploadPost({
    required String title,
    required String description,
    required File media,
  }) async {
    final response = await _apiClient.multipartRequest(
      'POST',
      ApiConfig.createPost,
      {'title': title, 'description': description},
      file: media,
      fileKey: 'media',
    );

    if (response.statusCode == 201) {
      return Post.fromJson(response.body);
    } else {
      throw Exception(response.statusText ?? "Error uploading post");
    }
  }

  Future<void> uploadRecipe(Recipe recipe) async {
    final response = await _apiClient.postRequest(
      ApiConfig.recipes,
      recipe.toJson(),
    );

    if (response.status.hasError) {
      return Future.error(response.statusText ?? "Error uploading recipe");
    }
  }
}
