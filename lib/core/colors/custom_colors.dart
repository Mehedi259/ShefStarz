import 'package:flutter/material.dart';

class MyColors extends ThemeExtension<MyColors> {
  final Color? customColor;

  const MyColors({required this.customColor});

  @override
  MyColors copyWith({Color? customColor}) {
    return MyColors(customColor: customColor ?? this.customColor);
  }

  @override
  MyColors lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(customColor: Color.lerp(customColor, other.customColor, t));
  }
}