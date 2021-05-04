import 'package:be_still/models/user.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_alert_dialog.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'essentials.dart';

class BeStilDialog {
  static Widget getLoading([String message = '']) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.backgroundImage(true)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Center(
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
                style: AppTextStyles.regularText15,
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showLoading(BuildContext context,
      [String message = '']) async {
    Navigator.of(context).push(Loader(message));
  }

  static hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static Future showErrorDialog(BuildContext context, dynamic error,
      UserModel user, StackTrace stackTrace) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => CustomAlertDialog(
        type: AlertType.error,
        confirmText: 'OK',
        message: error.message,
      ),
    );
    FirebaseCrashlytics.instance
        .setCustomKey('id', user == null ? 'N/A' : user.id);
    FirebaseCrashlytics.instance
        .setCustomKey('email', user == null ? 'N/A' : user.email);

    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
    );
  }

  static Future showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => CustomAlertDialog(
        type: AlertType.success,
        confirmText: 'OK',
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
    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.medium10.copyWith(color: AppColors.lightBlue3),
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
            ScaffoldMessenger.of(_scaffoldKey.currentContext)
                .hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class Loader extends ModalRoute<void> {
  final String message;
  Loader(this.message);
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
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
            style: AppTextStyles.regularText15,
          )
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
