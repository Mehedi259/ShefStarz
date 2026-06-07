import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import '../../../core/widgets/custom_input_auth/custom_input_auth.dart';
import '../controller/profile_completion_controller.dart';

class ProfileCompletionView extends GetView<ProfileCompletionController> {
  const ProfileCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            CustomHeaderAuth(
              titleFirstLine: "Complete Profile",
              titleSecondLine: "Just a few more details",
              isSubTextFSiz: true,
              height: Get.height * .22,
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Username Input
                    CustomInputAuth(
                      label: "Username",
                      hint: "Enter your username",
                      controller: controller.usernameController,
                      onChanged: controller.validateUsername,
                      validator: controller.validateUsername,
                      isValid: controller.usernameValid,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Age Group Dropdown
                    const Text(
                      "Age Group",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Obx(() => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedAgeGroup.value.isEmpty 
                            ? null 
                            : controller.selectedAgeGroup.value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          hintText: "Select your age group",
                        ),
                        items: controller.ageGroupList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.setAgeGroup(newValue);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select an age group";
                          }
                          return null;
                        },
                      ),
                    )),
                    
                    const SizedBox(height: 30),
                    
                    // Complete Profile Button
                    CustomLoadingButton(
                      text: "Complete Profile",
                      isLoading: controller.isLoading,
                      onTap: controller.submitProfileCompletion,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
