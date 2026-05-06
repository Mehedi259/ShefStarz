import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import 'package:pinput/pinput.dart';
import '../controller/auth_controller.dart';

class VerificationView extends GetView<AuthController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.paleYellow,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.verificationFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomHeaderAuth(
                titleFirstLine: "Enter\nVerification Code",
                // Fixed: Displaying forgotPasswordEmailController.text
                titleSecondLine:
                    '${AppStrings.emailVi}\n${controller.forgotPasswordEmailController.text}',
                isSubTextFSiz: true,
                height: Get.height * .20,
                mainFSiz: 23,
              ),
              const SizedBox(height: 20),
              Obx(
                () => ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    "00:${controller.resendTimerSeconds.value.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Pinput(
                  length: 6,
                  controller: controller.forgotPasswordOtpController,
                  validator: controller.validateForgotPasswordOtp,
                  onChanged: controller.validateForgotPasswordOtp,
                  onTap: () {
                    if (controller
                        .forgotPasswordOtpController
                        .text
                        .isNotEmpty) {
                      controller
                          .forgotPasswordOtpController
                          .selection = TextSelection(
                        baseOffset: 0,
                        extentOffset:
                            controller.forgotPasswordOtpController.text.length,
                      );
                    }
                  },
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red),
                    ),
                  ),
                  errorTextStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code? "),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.canResend.value
                          ? controller.resendForgotPasswordCode
                          : null,
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                          color: controller.canResend.value
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomLoadingButton(
                  text: "Verify Code",
                  isLoading: controller.isLoading,
                  onTap: controller.verifyCode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
