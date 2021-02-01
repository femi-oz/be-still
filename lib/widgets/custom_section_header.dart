import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomSectionHeder extends StatelessWidget {
  final String title;

  CustomSectionHeder(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.dropShadow,
            offset: Offset(0.0, 1.0),
            blurRadius: 6.0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: AppColors.prayerMenu,
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Text(
        title,
        style: AppTextStyles.boldText24.copyWith(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }
}
