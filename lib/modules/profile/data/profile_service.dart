import 'dart:io';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/user_model.dart';

class ProfileService extends GetxService {
  static ProfileService get to => Get.find<ProfileService>();

  Future<ProfileService> init() async {
    return this;
  }

  Future<UserModel?> getUserProfile(String id) async {
    final res = await ApiClient.to.getRequest('users/profiles/$id/');
    if (res.statusCode == 200 && res.body != null) {
      if (res.body is Map<String, dynamic>) {
        return UserModel.fromJson(res.body as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<UserModel?> updateUserProfile(
    String id,
    Map<String, dynamic> data, {
    File? profilePicture,
  }) async {
    Response res;
    if (profilePicture != null) {
      final Map<String, String> stringData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      res = await ApiClient.to.patchMultipartRequest(
        'users/profiles/$id/',
        stringData,
        file: profilePicture,
        fileKey: 'profile_picture',
      );
    } else {
      res = await ApiClient.to.patchRequest('users/profiles/$id/', data);
    }
    if (res.statusCode == 200 && res.body != null) {
      if (res.body is Map<String, dynamic>) {
        return UserModel.fromJson(res.body as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<bool> followUser(String id) async {
    final res = await ApiClient.to.postRequest(
      'users/profiles/$id/follow/',
      {},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> unfollowUser(String id) async {
    final res = await ApiClient.to.postRequest(
      'users/profiles/$id/unfollow/',
      {},
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<List<UserModel>> getFollowers(String id) async {
    if (id.trim().isEmpty) return [];
    final res = await ApiClient.to.getRequest('users/profiles/$id/followers/');
    if (res.statusCode == 200) {
      if (res.body is List) {
        return (res.body as List).map((e) => UserModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<List<UserModel>> getFollowing(String id) async {
    if (id.trim().isEmpty) return [];
    final res = await ApiClient.to.getRequest('users/profiles/$id/following/');
    if (res.statusCode == 200) {
      if (res.body is List) {
        return (res.body as List).map((e) => UserModel.fromJson(e)).toList();
      }
    }
    return [];
  }
}
