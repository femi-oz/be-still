import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class BeStillSnackbar {
  static showInSnackBar(
      {required GlobalKey<ScaffoldState> key,
      required String message,
      type = 'error'}) {
    ScaffoldMessenger.of(key.currentContext!).showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.prayerMenu[1],
        content: Row(
          children: [
            Icon(AppIcons.bestill_inappropriate,
                color: type == 'error'
                    ? AppColors.red.withOpacity(0.8)
                    : AppColors.white.withOpacity(0.8)),
            SizedBox(width: 10.0),
            Flexible(
              child: Text(
                message,
                style: AppTextStyles.regularText14
                    .copyWith(color: AppColors.splashTextColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
