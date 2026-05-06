import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../controller/profile_controller.dart';

class EditProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final selectedImagePath = ''.obs;

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final profileController = Get.find<ProfileController>();
      final fetchedUser = profileController.currentUser.value;
      if (fetchedUser != null) {
        user.value = fetchedUser;
        nameController.text = fetchedUser.name;
        emailController.text = fetchedUser.email;
        bioController.text = fetchedUser.bio ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (user.value == null) return;

    isLoading.value = true;
    try {
      Map<String, dynamic> data = {};
      if (nameController.text != user.value!.name) {
        data['username'] = nameController.text;
      }
      if (bioController.text != (user.value!.bio ?? '')) {
        data['bio'] = bioController.text;
      }

      File? imageFile;
      if (selectedImagePath.value.isNotEmpty) {
        imageFile = File(selectedImagePath.value);
      }

      if (data.isEmpty && imageFile == null) {
        Get.back(result: true);
        return;
      }

      final profileController = Get.find<ProfileController>();
      final success = await profileController.updateProfile(
        data,
        profilePicture: imageFile,
      );

      if (success) {
        Get.back(result: true);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
