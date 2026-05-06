import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/widgets/custom_gradient_loading_btn.dart';
import '../../../core/widgets/custom_header_auth/custom_header_auth.dart';
import 'package:pinput/pinput.dart';
import '../controller/auth_controller.dart';

class SingUpVerificationView extends GetView<AuthController> {
  const SingUpVerificationView({super.key});

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
          key: controller.signupVerificationFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomHeaderAuth(
                titleFirstLine: "Enter\nVerification Code",
                titleSecondLine:
                    '${AppStrings.emailVi}\n${controller.emailController.text}',
                isSubTextFSiz: true,
                height: Get.height * .20,
                mainFSiz: 23,
              ),
              const SizedBox(height: 20),
              // Timer
              // Obx(
              //   () => ShaderMask(
              //     shaderCallback: (bounds) =>
              //         AppColors.primaryGradient.createShader(bounds),
              //     child: Text(
              //       controller.formattedTime,
              //       style: const TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white, // Color is overridden by ShaderMask
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              // OTP Input
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Pinput(
                  length: 6,
                  controller: controller.signupOtpController,
                  validator: controller.validateSignupOtp,
                  onChanged: controller.validateSignupOtp,
                  onTap: () {
                    if (controller.signupOtpController.text.isNotEmpty) {
                      controller.signupOtpController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset:
                            controller.signupOtpController.text.length,
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
              // Resend Logic
              Obx(() {
                if (!controller.canResend.value) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Resend code in ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),

                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          '${controller.resendTimerSeconds.value}s',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Color is overridden by ShaderMask
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: controller.resendSignupCode,
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 10),
              // Verify Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomLoadingButton(
                  text: "Verify Code",
                  isLoading: controller.isLoading, // Pass the RxBool
                  onTap: controller.verifySignupCode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
