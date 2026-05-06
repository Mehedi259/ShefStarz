import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE23744);
  static const Color secondary = Color(0xFF2D2D2D);
  static const Color background = Colors.white;

  // Design Specific Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color paleYellow = Color(
    0xFFF8EAB0,
  ); // Approximate for the top container0xFFFFF9C4
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color iconColor = Color(0xFFE76F43);
  static const Color inputBorde1 = Color(0xFFE0CEAF);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF6502FE); // Purple
  static const Color gradientMiddle = Color(0xFFF2009A); // Red
  static const Color gradientEnd = Color(0xFFF40031); // Orange
  static const Color gradientEnd1 = Color(0xFFFCB800); // Orange

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientMiddle, gradientEnd,gradientEnd1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );




}
