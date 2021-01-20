import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomLogoShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return CustomPaint(
      painter: AuthCustomPainter(AppColors.backgroundColor.reversed.toList(), AppColors.shadowColor),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Image.asset(StringUtils.logo),
      ),
    );
  }
}

class AuthCustomPainter extends CustomPainter {
  final List<Color> colors;
  final Color shadowColor;

  @override
  AuthCustomPainter(this.colors, this.shadowColor);
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final rect = new Rect.fromLTWH(0, 0, width, height);

    final gradient = new LinearGradient(
      colors: colors,
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
