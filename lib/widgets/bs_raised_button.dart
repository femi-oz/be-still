import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class BsRaisedButton extends StatelessWidget {
  final BsRaisedButtonSize size;
  final BsRaisedButtonType type;
  final FontWeight fontWeight;
  final double fontSize;
  final double width;
  final bool applyBold;
  final bool fullWidth;
  final bool hasCorners;
  final bool hasShader;
  final bool disabled;

  final void Function() onPressed;

  const BsRaisedButton({
    Key key,
    this.width,
    this.size = BsRaisedButtonSize.normal,
    this.type = BsRaisedButtonType.primary,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 16,
    this.fullWidth = false,
    this.hasCorners = true,
    this.hasShader = false,
    this.applyBold = false,
    this.disabled = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        elevation: MaterialStateProperty.all<double>(0.0),
      ),
      child: Container(
        width: fullWidth ? double.maxFinite : width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: disabled
                ? [
                    AppColors.buttonGradient[0].withOpacity(0.5),
                    AppColors.buttonGradient[1].withOpacity(0.5)
                  ]
                : AppColors.buttonGradient,
          ),
        ),
        margin: const EdgeInsets.all(0),
        padding: EdgeInsets.symmetric(
          vertical: size.vertical,
          horizontal: size.horizontal,
        ),
        child: Icon(
          AppIcons.bestill_next_arrow,
          color: AppColors.white,
          size: 26,
        ),
      ),
      onPressed: disabled ? null : onPressed,
    );
  }
}

enum BsRaisedButtonType {
  primary,
  primaryInverse,
  accent,
  accentInverse,
}

class BsRaisedButtonSize {
  const BsRaisedButtonSize._([this.vertical, this.horizontal]);

  final double horizontal;
  final double vertical;

  static BsRaisedButtonSize custom(double vertical, double horizontal) {
    return BsRaisedButtonSize._(vertical, horizontal);
  }

  static const BsRaisedButtonSize xxlarge = BsRaisedButtonSize._(32, 8);
  static const BsRaisedButtonSize xlarge = BsRaisedButtonSize._(28, 8);
  static const BsRaisedButtonSize large = BsRaisedButtonSize._(24, 8);
  static const BsRaisedButtonSize normal = BsRaisedButtonSize._(14, 20);
  static const BsRaisedButtonSize small = BsRaisedButtonSize._(12, 8);
  static const BsRaisedButtonSize smaller = BsRaisedButtonSize._(10, 8);
}
