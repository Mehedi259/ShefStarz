import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/widgets/gradient_svg/gradient_svg.dart';

class NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
// final theme = Theme.of(context);
    // final color = active
    //     ? theme.primaryColor
    //     : (theme.iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.paleYellow
                : AppColors.background,
          ),
          child: active?GradientSvg(
            assetPath: icon, // e.g., MyAppImage.home
            gradient: AppColors.primaryGradient,
            size: 24,
          ):SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          )
        ),
      ),
    );
  }
}