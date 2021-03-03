import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
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
              color: AppColors.textFieldBorder,
            ),
            borderRadius: BorderRadius.circular(3.0),
            color: AppColors.textFieldBackgroundColor),
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                actionText,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTextStyles.regularText18b.copyWith(color: actionColor),
              ),
            ),
            SizedBox(width: 10),
            icon != ''
                ? Container(
                    height: 20,
                    child: Image.asset(
                      icon,
                    ),
                  )
                : Container(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textIcon != ''
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.asset(textIcon),
                        )
                      : Container(),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularText15.copyWith(
                          color: textColor == null
                              ? AppColors.textFieldText
                              : textColor),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
