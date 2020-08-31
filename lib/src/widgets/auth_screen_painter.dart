import 'package:flutter/material.dart';

class AuthCustomPainter extends CustomPainter {
  final startColor;
  final endColor;

  final shadowColor;

  @override
  AuthCustomPainter(this.startColor, this.endColor, this.shadowColor);
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final rect = new Rect.fromLTWH(0, 0, width, height);

    final gradient = new LinearGradient(
      colors: [
        startColor,
        endColor,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Path path = Path();

    final gardientPainter = new Paint()..shader = gradient.createShader(rect);
    path.lineTo(0, height * 0.4);
    path.lineTo(width * 0.46, height * 0.98);
    path.relativeQuadraticBezierTo(20, 15, 40, -5);
    path.lineTo(width, height * 0.4);
    path.lineTo(width, 0);
    path.close();
    canvas.drawShadow(path, shadowColor, 5.0, true);
    canvas.drawPath(path, gardientPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
