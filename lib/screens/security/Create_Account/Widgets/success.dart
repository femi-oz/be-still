import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:provider/provider.dart';

class CreateAccountSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Your account has been succesfully created.',
            style: TextStyle(
              color:
                  AppColors.getTextFieldText(_themeProvider.isDarkModeEnabled),
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
          Text(
            'Login to your BesStill...',
            style: TextStyle(
              color:
                  AppColors.getTextFieldText(_themeProvider.isDarkModeEnabled),
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
