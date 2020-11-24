import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final bool isDarkModeEnabled;
  final String actionText;
  final String value;
  final Color actionColor;
  final Function onPressed;
  final String textIcon;
  final String icon;
  final Color textColor;
  CustomOutlineButton({
    this.actionText,
    this.actionColor = AppColors.lightBlue4,
    this.textColor,
    this.isDarkModeEnabled,
    this.value,
    this.onPressed,
    this.textIcon = '',
    this.icon = '',
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.getTextFieldBorder(isDarkModeEnabled),
            ),
            borderRadius: BorderRadius.circular(3.0),
            color: AppColors.getTextFieldBgColor(isDarkModeEnabled)),
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              actionText,
              style: AppTextStyles.regularText18b.copyWith(color: actionColor),
            ),
            icon != ''
                ? Container(
                    height: 20,
                    child: Image.asset(
                      icon,
                    ),
                  )
                : Container(),
            Row(
              children: [
                textIcon != ''
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.asset(textIcon),
                      )
                    : Container(),
                Text(
                  value,
                  style: AppTextStyles.regularText16.copyWith(
                      color: textColor == null
                          ? AppColors.getTextFieldText(isDarkModeEnabled)
                          : textColor),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
