import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import '../../../core/widgets/custom_input_auth/custom_input_auth.dart';
import '../controller/auth_controller.dart';

class ParentView extends GetView<AuthController> {
  const ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.paleYellow,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // // Header
            CustomHeaderAuth(
              titleFirstLine: 'Need a',
              titleSecondLine: 'bit more info',
              height: Get.height * .15,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.parentFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input
                    // Name Input
                    CustomInputAuth(
                      label: "Our Chef Star Name",
                      hint: "Dankaplen",
                      controller: controller.nameController,
                      onChanged: controller.validateName,
                      validator: controller.validateName,
                      isValid: controller.nameValid,
                    ),
                    const SizedBox(height: 20),
                    // Email Input
                    // CustomInputAuth(
                    //   label: "User Email Address",
                    //   hint: "user@example.com",
                    //   controller: controller.emailController,
                    // ),
                    const SizedBox(height: 20),
                    // Age Group
                    const Text(
                      "Your Age Group",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Obx(
                      () => Row(
                        children: List.generate(
                          growable: true,
                          controller.ageList.length,
                          (index) => _buildAgeChip(
                            controller.ageList[index],
                            controller.selectedAgeGroup.value ==
                                index.toString(),
                            () => controller.setAgeGroup(index.toString()),
                            context,
                          ).marginOnly(right: 5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Parental Consent Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(
                          alpha: 0.1,
                        ), // Light green bg
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: Colors.orange,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Parental Consent",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "We'll send a short approval link to your parent.\nOnce they verify, your account will be unlocked.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: controller.parentEmailController,
                            onChanged: controller.validateParentEmail,
                            validator: controller.validateParentEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: "Parent's Email Address",
                              hintText: "example@gmail.com",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.orange,
                                ), // Custom matching AppColors
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                ), // Assuming default focus
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              suffixIcon: Obx(
                                () => controller.parentEmailValid.value
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Button
                    CustomLoadingButton(
                      text: "Send Parent's approval request",
                      isLoading: controller.isLoading, // Pass the RxBool
                      onTap: controller.submitParentInfo,
                    ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * .27,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.paleYellow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
