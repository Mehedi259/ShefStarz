import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/image/app_image.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import '../../../core/widgets/custom_input_auth/custom_input_auth.dart';
import '../../../core/widgets/custom_social_button/custom_social_button.dart';
import '../../../routes/app_pages.dart';
import '../controller/auth_controller.dart';
import '../controller/social_auth_controller.dart';

class SignupDetailsView extends GetView<AuthController> {
  const SignupDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            CustomHeaderAuth(
              titleFirstLine: AppStrings.signUp,
              titleSecondLine: AppStrings.welcomeBack,
              isSubTextFSiz: true,
              height: Get.height * .22,
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.signupFormKey,
                child: Column(
                  children: [
                    // Inputs
                    CustomInputAuth(
                      label: "Email",
                      hint: "Email",
                      controller: controller.emailController,
                      onChanged: controller.validateEmail,
                      validator: controller.validateEmail,
                      isValid: controller.emailValid,
                    ),
                    const SizedBox(height: 15),
                    CustomInputAuth(
                      label: "Password",
                      hint: "Password",
                      controller: controller.passController.value,
                      isPass: true,
                      obscureValue: controller.isObscure,
                      toggleVisibility: controller.togglePassword,
                      onChanged: controller.validatePassword,
                      validator: controller.validatePassword,
                      isValid: controller.passValid,
                      bottomWidget: Obx(() {
                        if (controller.passStrength.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        Color strengthColor = Colors.red;
                        if (controller.passStrength.value == "Medium") {
                          strengthColor = Colors.orange;
                        }
                        if (controller.passStrength.value == "Strong") {
                          strengthColor = Colors.green;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                          child: Text(
                            "Strength: ${controller.passStrength.value}",
                            style: TextStyle(
                              color: strengthColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: controller.navigateToForgotPassword,
                    //     child: const Text(
                    //       AppStrings.forgotPassword,
                    //       style: TextStyle(color: Colors.orange),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    // Sign In Button
                    CustomLoadingButton(
                      text: "Sign up",
                      isLoading: controller.isLoading, // Pass the RxBool
                      onTap: controller.submitSignup,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "OR SIGN IN WITH",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    // Social
                    CustomSocialButton(
                      text: "Log in with Apple",
                      icon: MyAppImage.apple,
                      onTap: () => Get.find<SocialAuthController>().loginWithApple(),
                    ),
                    const SizedBox(height: 15),
                    CustomSocialButton(
                      text: "Log in with Google",
                      icon: MyAppImage.google,
                      onTap: () => Get.find<SocialAuthController>().loginWithGoogle(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already account? "),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.LOGIN),
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
