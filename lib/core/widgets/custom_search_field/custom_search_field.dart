import 'package:flutter/material.dart';
import '../../../core/colors/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool isSearch;
  final ValueChanged<String>? onChanged;

  const CustomSearchField({
    super.key,
    required this.hintText,
    this.onTap,
    this.isSearch = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: AppColors.primaryGradient, // The "Border" Gradient
        ),
        padding: const EdgeInsets.all(1.5), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            onChanged: onChanged,
            enabled: isSearch ? true : (onTap == null ? true : false),
            autofocus: isSearch,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              prefixIcon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Icon(
                  Icons.search,
                  size: 28,
                  color: Colors.white, // Required for ShaderMask to work
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }
}
