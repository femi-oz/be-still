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

  static Future<void> showLoading(BuildContext context,
      [String message = '']) async {
    Navigator.of(context).push(Loader(message));
  }

  static hideLoading(BuildContext context) {
    Navigator.pop(context);
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
          style:
              AppTextStyles.medium10.copyWith(color: AppColors.splashTextColor),
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
