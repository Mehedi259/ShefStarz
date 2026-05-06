import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../trust_and_safety/controller/trust_and_safety_controller.dart';
import 'blocked_user_record_model.dart';

class BlockedUsersController extends GetxController {
  var isLoading = true.obs;
  var blockedUsers = <BlockedUserRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.to.getRequest(ApiConfig.blockedList);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is List) {
          blockedUsers.value = data.map((x) => BlockedUserRecord.fromJson(x)).toList();
        } else if (data != null && data['results'] is List) {
          blockedUsers.value = (data['results'] as List)
              .map((x) => BlockedUserRecord.fromJson(x))
              .toList();
        } else {
          blockedUsers.clear();
        }
      } else {
        Get.snackbar(
          'Error',
          response.statusText ?? 'Failed to load blocked users',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } on SocketException {
      Get.snackbar(
        'Network Error',
        'Unable to connect to the server. Please check your internet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on TimeoutException {
      Get.snackbar(
        'Timeout Error',
        'The server is taking too long to respond. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(BlockedUserRecord record) async {
    final trustSafetyController = Get.find<TrustAndSafetyController>();
    // USE the blockedUser.id (e.g. 74) NOT the record.id (e.g. 1)
    final userId = record.blockedUser.id;
    final parsedId = int.tryParse(userId) ?? 0;
    
    if (parsedId == 0) {
      Get.snackbar('Error', 'Invalid User ID', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final success = await trustSafetyController.unblockUser(parsedId);
    
    if (success) {
      // Instantly remove the record from the reactive list upon success
      blockedUsers.removeWhere((item) => item.id == record.id);
    }
  }
}
