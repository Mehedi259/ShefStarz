import 'package:chef_starz/core/image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_social_button/custom_social_button.dart';
import '../controller/auth_controller.dart';
import '../controller/social_auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // color: AppColors.background, // Background color from design
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Social Buttons
              CustomSocialButton(
                text: "Log in with Google",
                icon: MyAppImage.google,
                onTap: () => Get.find<SocialAuthController>().loginWithGoogle(),
              ),
              const SizedBox(height: 15),
              CustomSocialButton(
                text: "Log in with Apple",
                icon: MyAppImage.apple,
                onTap: () => Get.find<SocialAuthController>().loginWithApple(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: controller.navigateToLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          // Use ClipRRect to ensure both image AND gradient are rounded
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 1. The Background Image
                Image.asset(
                  MyAppImage.step_1,
                  width: Get.width,
                  height: Get.height * 0.7, // Adjust height as needed
                  fit: BoxFit.cover,
                ),

                // 2. The Gradient Overlay (White at bottom, transparent at top)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(
                          0xFFFFFFFF,
                        ).withValues(alpha: 0.9), // Strong white at bottom
                        const Color(
                          0xFFFFFFFF,
                        ).withValues(alpha: 0.0), // Fades to nothing
                      ],
                      stops: const [
                        0.0,
                        0.4,
                      ], // Controls how high the white goes
                    ),
                  ),
                ),

                // 3. The Text Content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        AppStrings.registerNow,
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        AppStrings.chooseMethod,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
