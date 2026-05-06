import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../auth/data/auth_service.dart';
import '../data/settings_repository.dart';
import '../../../core/theme/theme_service.dart';

class SettingsController extends GetxController {
  final SettingsRepository _repository = SettingsRepository();

  final pushNotifications = true.obs;
  final comments = true.obs;
  final parentalControls = true.obs;
  final isDarkMode = (ThemeService.to.isDarkMode).obs;

  @override
  void onInit() {
    super.onInit();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final settings = await _repository.getSettings();
      pushNotifications.value = settings.notifications;
      comments.value = settings.comments;
      parentalControls.value = settings.parentalControl;
      if (isDarkMode.value != settings.darkMode) {
        // Only toggle locally if different from server
        ThemeService.to.toggleTheme();
        isDarkMode.value = settings.darkMode;
      }
    } catch (e) {
      Get.log("Failed to fetch settings: $e");
    }
  }

  Future<void> _updateSettingOnServer(Map<String, dynamic> data) async {
    try {
      await _repository.updateSettings(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings');
      rethrow;
    }
  }

  void toggleDarkMode(bool value) async {
    final previousValue = isDarkMode.value;
    ThemeService.to.toggleTheme();
    isDarkMode.value = value;
    try {
      await _updateSettingOnServer({'dark_mode': value});
    } catch (e) {
      isDarkMode.value = previousValue;
      ThemeService.to.toggleTheme(); // Revert theme toggle
    }
  }

  void toggleNotifications(bool value) async {
    final previousValue = pushNotifications.value;
    pushNotifications.value = value;
    try {
      await _updateSettingOnServer({'notifications': value});
    } catch (e) {
      pushNotifications.value = previousValue;
    }
  }

  void toggleComments(bool value) async {
    final previousValue = comments.value;
    comments.value = value;
    try {
      await _updateSettingOnServer({'comments': value});
    } catch (e) {
      comments.value = previousValue;
    }
  }

  void toggleParentalControls(bool value) async {
    final previousValue = parentalControls.value;
    parentalControls.value = value;
    try {
      await _updateSettingOnServer({'parental_control': value});
    } catch (e) {
      parentalControls.value = previousValue;
    }
  }

  void logout() async {
    try {
      await AuthService.to.logout();
    } catch (e) {
      Get.log("Settings logout navigation boundary error: $e");
    } finally {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                // Show loading
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                await AuthService.to.deleteAccount();
                // Navigation to Login is handled inside AuthService.deleteAccount()
              } catch (e) {
                Get.back(); // Close loading
                Get.snackbar(
                  "Error",
                  "Failed to delete account: $e",
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
