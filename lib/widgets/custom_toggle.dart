import 'dart:io' show Platform;
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final Function onChange;
  final bool value;
  final bool hasText;
  final bool disabled;
  final String? title;
  CustomToggle(
      {required this.value,
      required this.onChange,
      this.title,
      this.hasText = true,
      this.disabled = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hasText ? 20.0 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (hasText)
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                title ?? '',
                style: AppTextStyles.regularText15.copyWith(
                  color:
                      AppColors.textFieldText.withOpacity(disabled ? 0.3 : 1),
                ),
              ),
            ),
          Platform.isIOS
              ? CupertinoSwitch(
                  value: disabled ? false : value,
                  activeColor: AppColors.lightBlue4,
                  trackColor: Colors.grey[400],
                  onChanged: disabled ? null : (value) => onChange(value),
                )
              : Switch(
                  value: disabled ? false : value,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
                  inactiveThumbColor: Colors.white,
                  onChanged: disabled ? null : (value) => onChange(value),
                ),
        ],
      ),
    );
  }
}
