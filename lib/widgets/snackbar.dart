import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeStillSnackbar {
  static showInSnackBar({GlobalKey<ScaffoldState> key, String message}) {
    key.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.getPrayerMenu(
            Provider.of<ThemeProvider>(key.currentContext, listen: false)
                .isDarkModeEnabled)[1],
        content: Row(
          children: [
            Icon(Icons.error, color: AppColors.red.withOpacity(0.8)),
            SizedBox(width: 10.0),
            Text(message),
          ],
        ),
      ),
    );
  }
}
