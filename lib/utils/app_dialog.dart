import 'package:be_still/models/user.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_alert_dialog.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'essentials.dart';

class BeStilDialog {
  static Widget getLoading(context, [String message = '']) {
    precacheImage(AssetImage(StringUtils.backgroundImage), context);
    return Scaffold(
      appBar: CustomAppBar(switchSearchMode: () {}, globalKey: GlobalKey()),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.backgroundImage),
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
    await Navigator.of(context).push(Loader(message));
  }

  static hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static Future showErrorDialog(BuildContext context, String error,
      UserModel user, StackTrace stackTrace) async {
    // bool hasProperty = false;
    // try {
    //   (error as PlatformException).message;
    //   hasProperty = true;
    // } on NoSuchMethodError {}
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => CustomAlertDialog(
        type: AlertType.error,
        confirmText: 'OK',
        message: error.capitalizeFirst ?? '',
      ),
    );
    FirebaseCrashlytics.instance.setUserIdentifier(user.id);
    FirebaseCrashlytics.instance.setCustomKey('id', user.id);
    FirebaseCrashlytics.instance.setCustomKey('email', user.email);

    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
    );
  }

  static Future showSuccessDialog(BuildContext context, String message,
      {Function? onConfirm}) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => CustomAlertDialog(
          type: AlertType.success,
          confirmText: 'OK',
          message: message,
          onConfirm: onConfirm),
    );
  }

  static Future showConfirmDialog(BuildContext context,
      {String? title, String? message, required Function onConfirm}) async {
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
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
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
            ScaffoldMessenger.of(_scaffoldKey.currentContext!)
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
  String get barrierLabel => '';

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
