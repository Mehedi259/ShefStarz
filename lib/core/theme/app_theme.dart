import 'package:chef_starz/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

import '../colors/custom_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFFFF9E7), // AppColors.paleYellow
    dividerColor: Colors.grey[200],

    // Add Custom Colors here
    extensions: [
      MyColors(customColor: AppColors.background), // AppColors.background
    ],

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    // ... rest of your textTheme and colorScheme
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),

    // Add Custom Colors for Dark mode
    extensions: const [
      MyColors(customColor: Color(0xFF000000)),
    ],

    // ... rest of your dark theme
  );
}
