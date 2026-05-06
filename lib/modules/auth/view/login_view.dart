import 'package:chef_starz/core/image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import '../../../core/widgets/custom_input_auth/custom_input_auth.dart';
import '../../../core/widgets/custom_social_button/custom_social_button.dart';
import '../controller/auth_controller.dart';
import '../controller/social_auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeaderAuth(
              titleFirstLine: AppStrings.signIn,
              titleSecondLine: AppStrings.welcomeBack,
              isSubTextFSiz: true,
              height: Get.height * .22,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
                    CustomInputAuth(
                      label: "Email",
                      hint: "Email",
                      controller: controller.loginEmailController,
                      onChanged: controller.validateLoginEmail,
                      validator: controller.validateLoginEmail,
                      isValid: controller.loginEmailValid,
                    ),
                    const SizedBox(height: 15),
                    CustomInputAuth(
                      label: "Password",
                      hint: "Password",
                      controller: controller.loginPassController,
                      isPass: true,
                      obscureValue: controller.isLoginObscure,
                      toggleVisibility: controller.toggleLoginPassword,
                      onChanged: controller.validateLoginPassword,
                      validator: controller.validateLoginPassword,
                      isValid: controller.loginPassValid,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.navigateToForgotPassword,
                        child: const Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomLoadingButton(
                      text: "Sign in",
                      isLoading: controller.isLoading,
                      onTap: controller.submitLogin,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "OR SIGN IN WITH",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: controller.navigateToSignupDetails,
                          child: const Text(
                            "Sign up",
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