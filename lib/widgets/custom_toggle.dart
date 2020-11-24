import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomToggle extends StatelessWidget {
  final Function onChange;
  final bool value;
  final String title;
  CustomToggle({this.value, this.onChange, this.title});
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              title,
              style: AppTextStyles.regularText16.copyWith(
                color: AppColors.getTextFieldText(
                    _themeProvider.isDarkModeEnabled),
              ),
            ),
          ),
          Switch.adaptive(
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
