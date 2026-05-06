import 'package:flutter/material.dart';

class CurvedNavBackground extends StatelessWidget {
  const CurvedNavBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, double.infinity),
      painter: _NavPainter(),
    );
  }
}

class _NavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerRadius = 20.0;
    const bumpWidth = 76.0;
    const bumpHeight = 26.0;
    final centerX = size.width / 2;

    final path = Path()
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(centerX - bumpWidth * 0.7, 0)
      ..cubicTo(
        centerX - bumpWidth * 0.4,
        0,
        centerX - bumpWidth * 0.4,
        -bumpHeight,
        centerX,
        -bumpHeight,
      )
      ..cubicTo(
        centerX + bumpWidth * 0.4,
        -bumpHeight,
        centerX + bumpWidth * 0.4,
        0,
        centerX + bumpWidth * 0.7,
        0,
      )
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black, 8, false);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}