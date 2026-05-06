import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';

class LocationController extends GetxController {
  final UserRepository _repository = UserRepository();

  final locationController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill location if available (could be passed via arguments or fetched)
    locationController.text = Get.arguments?['location'] ?? '';
  }

  Future<void> updateLocation() async {
    if (locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a location');
      return;
    }

    isLoading.value = true;
    try {
      final success = await _repository.updateLocation(locationController.text);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Location updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update location');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    locationController.dispose();
    super.onClose();
  }
}
