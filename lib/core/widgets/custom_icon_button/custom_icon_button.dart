import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;

  const CustomBackButton({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.iconColor, this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 52,
      margin:  const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        // Uses provided color or defaults to paleYellow
        color: backgroundColor ?? const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        // Adjusts padding to center the 'ios' icon properly
        icon: Center(
          child: Icon(
            icon??Icons.arrow_back_ios_new,
            color: iconColor ?? Colors.orange,
            size: 20,
          ),
        ),
        onPressed: onTap ?? () => Get.back(),
      ),
    );
  }
}