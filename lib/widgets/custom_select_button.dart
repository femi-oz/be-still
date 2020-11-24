import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSelectButton extends StatelessWidget {
  final bool isSelected;
  final Function onSelected;
  final String title;
  CustomSelectButton({this.isSelected, this.title, this.onSelected});
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                .withOpacity(0.3)
            : Colors.transparent,
        border: Border.all(
          color: AppColors.getCardBorder(_themeProvider.isDarkModeEnabled),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: OutlineButton(
        borderSide: BorderSide(color: Colors.transparent),
        child: Container(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
                color: AppColors.lightBlue3,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
        onPressed: () => onSelected(title),
      ),
    );
  }
}
