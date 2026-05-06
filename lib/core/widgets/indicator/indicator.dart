import 'package:chef_starz/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class Indicator {
  static Widget indicator(PageController pageController) => SmoothPageIndicator(
    controller: pageController,
    count: 3,
    effect:  ExpandingDotsEffect(
      expansionFactor: 3,
      spacing: 2,
      radius: 20,
      dotWidth: 12,
      dotHeight: 10,
      dotColor: AppColors.background,
      activeDotColor: AppColors.gradientEnd1,
    ),
  );
}
