import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSectionHeder extends StatelessWidget {
  final String title;

  CustomSectionHeder(this.title);
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.getDropShadow(_themeProvider.isDarkModeEnabled),
            offset: Offset(0.0, 1.0),
            blurRadius: 6.0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(
            color: AppColors.offWhite2,
            fontSize: 22,
            fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }
}
