import 'dart:io' show Platform;
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final Function onChange;
  final bool value;
  final String title;
  CustomToggle({this.value, this.onChange, this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
                  trackColor: Colors.white,
                  onChanged: (value) => onChange(value),
                )
              : Switch.adaptive(
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
