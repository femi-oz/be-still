import 'package:flutter/material.dart';
import './../utils/app_theme.dart';

class BeStillSnackbar {
  static showInSnackBar({GlobalKey<ScaffoldState> key, String message}) {
    key.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: key.currentContext.prayerMenuEnd,
        content: Row(
          children: [
            Icon(Icons.error,
                color: key.currentContext.prayerCardTags.withOpacity(0.8)),
            SizedBox(width: 10.0),
            Text(message),
          ],
        ),
      ),
    );
  }
}
