import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../routes/app_pages.dart';
import '../data/auth_service.dart';
import '../../../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileCompletionController extends GetxController {
  final usernameController = TextEditingController();
  final selectedAgeGroup = ''.obs;
  
  final isLoading = false.obs;
  final usernameError = RxnString();
  final usernameValid = false.obs;
  
  final profileFormKey = GlobalKey<FormState>();
  
  final List<String> ageGroupList = [
    '05-10 yrs',
    '11-15 yrs',
    '16-20 yrs',
  ];

  final ApiClient _apiClient = ApiClient.to;

  void setAgeGroup(String ageGroup) {
    selectedAgeGroup.value = ageGroup;
  }

  String? validateUsername(String? value) {
    final text = value?.trim() ?? '';
    String? errorResult;
    bool validResult = false;

    if (text.isEmpty) {
      errorResult = "Username is required";
    } else if (text.length < 3) {
      errorResult = "Username must be at least 3 characters";
    } else {
      validResult = true;
    }

    Future.microtask(() {
      usernameError.value = errorResult;
      usernameValid.value = validResult;
    });
    return errorResult;
  }

  Future<void> submitProfileCompletion() async {
    FocusManager.instance.primaryFocus?.unfocus();
    
    if (!profileFormKey.currentState!.validate()) {
      return;
    }

    if (selectedAgeGroup.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select an age group",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Get current user email from stored data
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        Get.snackbar(
          "Error",
          "User data not found. Please login again.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final userData = jsonDecode(userDataString);
      
      // Update local user data directly for social login users
      // Backend doesn't have a proper update endpoint for already verified users
      userData['username'] = usernameController.text.trim();
      userData['age_group'] = selectedAgeGroup.value;
      await prefs.setString('user_data', jsonEncode(userData));
      
      // Update AuthService
      try {
        final userModel = UserModel(
          id: userData['id']?.toString() ?? '',
          username: usernameController.text.trim(),
          email: userData['email'] ?? '',
          parentEmail: userData['parent_email'] ?? userData['email'] ?? '',
          isEmailVerified: userData['is_verified'] ?? true,
        );
        AuthService.to.currentUser.value = userModel;
      } catch (_) {
        // AuthService not initialized
      }

      Get.snackbar(
        "Success",
        "Profile completed successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Small delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
