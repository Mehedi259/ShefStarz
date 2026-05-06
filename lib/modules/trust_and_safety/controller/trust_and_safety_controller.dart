import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../home/data/home_service.dart';
import '../../recipes/data/recipe_service.dart';

class TrustAndSafetyController extends GetxController {
  static TrustAndSafetyController get to => Get.find();

  final RxSet<int> blockedUserIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUserIds();
  }

  /// Fetches the list of blocked users to initialize the reactive set
  Future<void> fetchBlockedUserIds() async {
    try {
      final response = await ApiClient.to.getRequest(ApiConfig.blockedList);
      if (response.statusCode == 200) {
        final data = response.body;
        List usersList = [];
        if (data is List) {
          usersList = data;
        } else if (data != null && data['results'] is List) {
          usersList = data['results'];
        }
        
        final ids = usersList
            .map((u) => int.tryParse(u['id']?.toString() ?? ''))
            .whereType<int>()
            .toSet();
        blockedUserIds.assignAll(ids);
      }
    } on SocketException {
      _showErrorSnackbar('Network Error: Unable to connect to the server.');
    } on TimeoutException {
      _showErrorSnackbar('Connection Timeout: The server is taking too long to respond.');
    } catch (e) {
      Get.log("Failed to fetch blocked users: $e");
    }
  }

  /// Blocks a user.
  Future<bool> blockUser(int blockedUserId) async {
    try {
      final response = await ApiClient.to.postRequest(
        ApiConfig.blockUser,
        {"blocked_user_id": blockedUserId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        blockedUserIds.add(blockedUserId);
        
        // Remove their posts and recipes from the feeds immediately
        if (Get.isRegistered<HomeService>()) {
          HomeService.to.removePostsByUser(blockedUserId);
        }
        if (Get.isRegistered<RecipeService>()) {
          RecipeService.to.removeRecipesByUser(blockedUserId);
        }
        
        Get.snackbar(
          'Success',
          'User blocked. Their posts have been hidden.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        _showErrorSnackbar(response.statusText ?? 'Failed to block user');
        return false;
      }
    } on SocketException {
      _showErrorSnackbar('Network Error: Unable to reach the server.');
      return false;
    } on TimeoutException {
      _showErrorSnackbar('Connection Timeout: Please check your internet.');
      return false;
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    }
  }

  /// Unblocks a user.
  Future<bool> unblockUser(int blockedUserId) async {
    try {
      final response = await ApiClient.to.postRequest(
        ApiConfig.unblockUser,
        {"blocked_user_id": blockedUserId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        blockedUserIds.remove(blockedUserId);
        Get.snackbar(
          'Success',
          'User has been unblocked successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        _showErrorSnackbar(response.statusText ?? 'Failed to unblock user');
        return false;
      }
    } on SocketException {
      _showErrorSnackbar('Network Error: Unable to reach the server.');
      return false;
    } on TimeoutException {
      _showErrorSnackbar('Connection Timeout: Please try again.');
      return false;
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    }
  }

  /// Reports a user, post, or comment.
  /// [targetType] should be one of "recipe", "comment", "user", or "post".
  Future<bool> report({
    required int targetId,
    required String targetType,
    required String reason,
  }) async {
    try {
      final response = await ApiClient.to.postRequest(
        ApiConfig.report,
        {
          "target_id": targetId,
          "target_type": targetType,
          "reason": reason,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Report Submitted',
          'Thank you for keeping our community safe. We will review your report.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        _showErrorSnackbar(response.statusText ?? 'Failed to submit report');
        return false;
      }
    } on SocketException {
      _showErrorSnackbar('Network Error: Unable to reach the server.');
      return false;
    } on TimeoutException {
      _showErrorSnackbar('Connection Timeout: Please try again.');
      return false;
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
