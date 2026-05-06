import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors/app_colors.dart';

class CustomLoadingButton extends StatelessWidget {
  final String text;
  final RxBool isLoading; // Accepts a GetX observable boolean
  final VoidCallback onTap;
  final Gradient? gradient;

  const CustomLoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          // Uses your AppColors gradient or a fallback
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: isLoading.value ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isLoading.value
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}