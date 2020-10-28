import 'package:be_still/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'essentials.dart';

class BeStilDialog {
  static Widget getLoading([String message = 'Loading...']) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(color: AppColors.lightBlue1, size: 50.0),
          SizedBox(height: 10.0),
          Text(message)
        ],
      ),
    );
  }

  static Future<void> showLoading(
      BuildContext context, GlobalKey key, bool isDarkMode,
      [String message = 'Loading...']) async {
    Dialog dialog = Dialog(
      key: key,
      insetPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.35, horizontal: 50),
      backgroundColor:
          AppColors.getBackgroudColor(isDarkMode)[0].withOpacity(0.8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(
            color: AppColors.lightBlue1,
            size: 50.0,
          ),
          SizedBox(height: 10.0),
          Text(
            message,
            style: AppTextStyles.regularText16,
          )
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  static hideLoading(GlobalKey key) {
    Navigator.of(key.currentContext, rootNavigator: true).pop();
  }

  static Future showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (_) => CustomAlertDialog(
        type: AlertType.error,
        confirmText: 'Close',
        message: message,
      ),
    );
  }

  static Future showConfirmDialog(BuildContext context,
      {String title, String message, Function onConfirm}) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => CustomAlertDialog(
        title: title ?? 'Confirmation',
        type: AlertType.warning,
        message: message ?? 'Are you sure want to proceed?',
        showCancelButton: true,
        confirmText: 'Yes!',
        onConfirm: onConfirm,
      ),
    );
  }

  static void showSnackBar(
      GlobalKey<ScaffoldState> _scaffoldKey, String message,
      [AlertType type = AlertType.success]) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: type == AlertType.info
            ? AppColors.lightBlue2
            : type == AlertType.error
                ? Colors.red
                : type == AlertType.success
                    ? Colors.green
                    : Colors.blueGrey,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'CLOSE',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
