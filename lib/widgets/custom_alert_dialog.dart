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
  final Function onConfirm;
  final Function onCancel;
  final bool showCancelButton;

  CustomAlertDialog({
    this.title = '',
    this.message,
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
          Text(
            title.isEmpty ? _getTitle(type) : title,
            style: AppTextStyles.regularText13.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Divider(),
          Text(
            message ?? 'An error occured!',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.maxFinite,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      confirmText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    color: _getColor(type),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) {
                        onConfirm();
                      }
                    },
                  ),
                ),
                if (showCancelButton)
                  Expanded(
                    child: FlatButton(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(cancelText),
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) {
                          onCancel();
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
      case AlertType.info:
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
        return 'Oops!';
      case AlertType.info:
      default:
        return '';
    }
  }
}
