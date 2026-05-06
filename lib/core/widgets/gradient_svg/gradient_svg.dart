import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientSvg extends StatelessWidget {
  final String assetPath;
  final double size;
  final Gradient gradient;

  const GradientSvg({
    super.key,
    required this.assetPath,
    required this.gradient,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      // BlendMode.srcIn ensures the gradient only fills the visible parts of the SVG
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        // The color must be white for the ShaderMask to apply the gradient correctly
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}