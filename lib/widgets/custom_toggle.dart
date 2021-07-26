import 'dart:io' show Platform;
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final Function onChange;
  final bool value;
  final bool hasText;
  final String title;
  CustomToggle({this.value, this.onChange, this.title, this.hasText = true});
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
                title,
                style: AppTextStyles.regularText15.copyWith(
                  color: AppColors.textFieldText,
                ),
              ),
            ),
          Platform.isIOS
              ? CupertinoSwitch(
                  value: value,
                  activeColor: AppColors.lightBlue4,
                  trackColor: Colors.grey[400],
                  onChanged: (value) => onChange(value),
                )
              : Switch(
                  value: value,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
                  inactiveThumbColor: Colors.white,
                  onChanged: (value) => onChange(value),
                ),
        ],
      ),
    );
  }
}
