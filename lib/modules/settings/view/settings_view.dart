import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../core/image/app_image.dart';
import '../../../core/widgets/custom_social_button/custom_social_button.dart';
import '../controller/settings_controller.dart';
import '../../profile/controller/profile_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.orange,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildItem(
            context,
            title: "Edit profile",
            onTap: () {
              Get.toNamed(Routes.EDIT_PROFILE)?.then((isUpdated) {
                if (isUpdated == true) {
                  if (Get.isRegistered<ProfileController>()) {
                    Get.find<ProfileController>().refreshProfileData();
                  }
                }
              });
            },
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Recent Activity",
            onTap: () => Get.toNamed(Routes.RECENT_ACTIVITY),
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Location Settings",
            onTap: () {
              final TextEditingController locationController =
                  TextEditingController();
              ProfileController? profileController;

              if (Get.isRegistered<ProfileController>()) {
                profileController = Get.find<ProfileController>();
              } else {
                profileController = Get.put(ProfileController());
              }
              locationController.text = profileController!.location.value;

              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Update Location",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your current city or area",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: "e.g. Dhaka, Bangladesh",
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.orange,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (locationController.text.trim().isNotEmpty) {
                                  Get.back(); // close bottom sheet
                                  profileController!.updateUserLocation(
                                    locationController.text.trim(),
                                  );
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Location cannot be empty",
                                  );
                                }
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ), // Padding for bottom safe area
                    ],
                  ),
                ),
                isScrollControlled: true,
              );
            },
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Saved Recipes/Photos/Videos",
            onTap: () => Get.toNamed(Routes.SAVED),
            // Routes.SAVED points to the same `SavedView` UI that resembles the wireframe.
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Blocked Users",
            onTap: () => Get.toNamed(Routes.BLOCKED_USERS),
          ),
          Divider(color: theme.dividerColor),

          const SizedBox(height: 20),

          Obx(
            () => _buildSwitchItem(
              context,
              "Dark Mode",
              controller.isDarkMode,
              onChanged: controller.toggleDarkMode,
            ),
          ),
          Divider(color: theme.dividerColor),
          Obx(
            () => _buildSwitchItem(
              context,
              "Receive push notifications",
              controller.pushNotifications,
              onChanged: controller.toggleNotifications,
            ),
          ),
          Divider(color: theme.dividerColor),
          Obx(
            () => _buildSwitchItem(
              context,
              "Comments",
              controller.comments,
              onChanged: controller.toggleComments,
            ),
          ),
          Divider(color: theme.dividerColor),
          Obx(
            () => _buildSwitchItem(
              context,
              "Parental Controls",
              controller.parentalControls,
              onChanged: controller.toggleParentalControls,
            ),
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Terms & Conditions",
            onTap: () => Get.toNamed(Routes.TERMS),
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "About Us",
            onTap: () => Get.toNamed(Routes.ABOUT),
          ),
          Divider(color: theme.dividerColor),
          _buildItem(
            context,
            title: "Delete Account",
            textColor: Colors.red,
            onTap: controller.confirmDeleteAccount,
          ),

          const SizedBox(height: 40),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: CustomSocialButton(
              text: "Sign out",
              icon: MyAppImage.signOut,
              onTap: controller.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.orange,
      ),
      onTap: onTap ?? () {},
    );
  }

  // ... rest of your code ...

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    RxBool value, {
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      // We replace the standard Switch with your custom gradient one
      trailing: _buildGradientSwitch(value, onChanged),
    );
  }

  Widget _buildGradientSwitch(RxBool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Gradient applied only when active
          gradient: value.value ? AppColors.primaryGradient : null,
          color: value.value ? null : Colors.grey[300],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
