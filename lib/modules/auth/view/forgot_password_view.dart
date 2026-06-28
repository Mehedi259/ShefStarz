import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart'; // Ensure this points to the Loading Button
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [],
        backgroundColor: AppColors.paleYellow,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeaderAuth(
              titleFirstLine: 'Forgot Password',
              titleSecondLine: 'Enter your email address \nto reset your password',
              isSubTextFSiz: true,
              height: Get.height * .17,
              mainFSiz: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.forgotPasswordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final isValid = controller.forgotPasswordEmailValid.value;
                      return TextFormField(
                        controller: controller.forgotPasswordEmailController,
                        onChanged: controller.validateForgotPasswordEmail,
                        validator: controller.validateForgotPasswordEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: "",
                          labelText: "Email",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.inputBorde1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.inputBorde1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.orange),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          suffixIcon: isValid
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    // Added CustomLoadingButton here
                    CustomLoadingButton(
                      text: 'Continue',
                      isLoading: controller.isLoading,
                      onTap: controller.submitForgotPassword,
                    ),
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