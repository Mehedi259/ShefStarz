import 'package:chef_starz/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final double fontSize;
  final VoidCallback? onTap;

  const CustomGradientButton({
    super.key,
    required this.text,
    this.onTap,
    this.fontSize = 18,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        // The outer container acts as the 1px gradient border
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppColors.primaryGradient,
        ),
        padding: const EdgeInsets.all(1), // Border thickness
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.background,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
