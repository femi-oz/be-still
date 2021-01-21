import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class BeStillSnackbar {
  static showInSnackBar({GlobalKey<ScaffoldState> key, String message}) {
    key.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.prayerMenu[1],
        content: Row(
          children: [
            Icon(Icons.error, color: AppColors.red.withOpacity(0.8)),
            SizedBox(width: 10.0),
            Text(
              message,
              style: AppTextStyles.regularText14
                  .copyWith(color: AppColors.splashTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
