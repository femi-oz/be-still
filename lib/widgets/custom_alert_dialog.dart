import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

enum AlertType {
  info,
  success,
  warning,
  error,
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final AlertType type;
  final Function? onConfirm;
  final Function? onCancel;
  final bool showCancelButton;

  CustomAlertDialog({
    this.title = '',
    this.message = 'An error occured!',
    this.confirmText = 'Ok',
    this.cancelText = 'Cancel',
    this.type = AlertType.info,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10.0),
          Icon(
            _getIcon(type),
            color: _getColor(type),
            size: 50,
          ),
          const SizedBox(height: 10.0),
          title.isNotEmpty
              ? Text(
                  title.isEmpty ? _getTitle(type) : title,
                  style: AppTextStyles.regularText13
                      .copyWith(fontSize: 18, color: AppColors.lightBlue4),
                  textAlign: TextAlign.center,
                )
              : Container(),
          Divider(),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.regularText16b
                  .copyWith(color: AppColors.lightBlue4),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    child: Text(confirmText,
                        style: AppTextStyles.boldText16
                            .copyWith(color: Colors.white)),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                          AppTextStyles.boldText16
                              .copyWith(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(5.0)),
                      elevation: MaterialStateProperty.all<double>(0.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    },
                  ),
                ),
                if (showCancelButton)
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.all(5.0)),
                      ),
                      child: Text(cancelText),
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) {
                          onCancel!();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Colors.orange;
      case AlertType.success:
        return Colors.green;
      case AlertType.error:
        return Colors.red;
      case AlertType.info:
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Icons.warning;
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
      default:
        return Icons.info_outline;
    }
  }

  String _getTitle(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return 'Warning';
      case AlertType.success:
        return 'Success';
      case AlertType.error:
        return '';
      case AlertType.info:
      default:
        return '';
    }
  }
}
