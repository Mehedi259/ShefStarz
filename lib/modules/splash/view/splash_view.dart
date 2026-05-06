import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/image/app_image.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/gradient_text/gradient_text.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring controller is found even if binding is lazy
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asset Logo
            Image.asset(MyAppImage.appLogo, width: 150, height: 150),
            const SizedBox(height: 10),

            SizedBox(height: 200),
            const Text(
              AppStrings.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            GradientText(
              AppStrings.tagline2,
              style: const TextStyle(fontSize: 22),
              gradient: AppColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }
}
