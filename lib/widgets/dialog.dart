// import 'package:flutter/material.dart';
// import './../utils/app_theme.dart';

// class BeStilDialog_ {
//   // static Future<void> showLoading(
//   //     BuildContext context, GlobalKey key, Color color,
//   //     [String message = 'Loading...']) async {
//   //   Dialog dialog = Dialog(
//   //     key: key,
//   //     insetPadding: EdgeInsets.symmetric(
//   //         vertical: MediaQuery.of(context).size.height * 0.35, horizontal: 50),
//   //     backgroundColor: AppColors.offWhite1,
//   //     shape: RoundedRectangleBorder(
//   //       side: BorderSide(color: Colors.blue[800]),
//   //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//   //     ),
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         CircularProgressIndicator(
//   //           valueColor: AlwaysStoppedAnimation(color),
//   //         ),
//   //         SizedBox(height: 10.0),
//   //         Text(message)
//   //       ],
//   //     ),
//   //   );

//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return dialog;
//   //     },
//   //   );
//   // }

//   // static hideLoading(GlobalKey key) {
//   //   Navigator.of(key.currentContext, rootNavigator: true).pop();
//   // }

//   static Future showErrorDialog(BuildContext context, String message) async {
//     await showDialog(
//       context: context,
//       builder: (_) => CustomAlertDialog(
//         type: AlertType.error,
//         confirmText: 'Close',
//         message: message,
//       ),
//     );
//   }

//   static Future showConfirmDialog(BuildContext context,
//       {String title, String message, Function onConfirm}) async {
//     showDialog(
//       context: context,
//       builder: (BuildContext ctx) => CustomAlertDialog(
//         title: title ?? 'Confirmation',
//         type: AlertType.warning,
//         message: message ?? 'Are you sure want to proceed?',
//         showCancelButton: true,
//         confirmText: 'Yes!',
//         onConfirm: onConfirm,
//       ),
//     );
//   }
// }

// enum AlertType {
//   info,
//   success,
//   warning,
//   error,
// }

// class CustomAlertDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   final String confirmText;
//   final String cancelText;
//   final AlertType type;
//   final Function onConfirm;
//   final Function onCancel;
//   final bool showCancelButton;

//   CustomAlertDialog({
//     this.title = '',
//     this.message,
//     this.confirmText = 'Ok',
//     this.cancelText = 'Cancel',
//     this.type = AlertType.info,
//     this.onConfirm,
//     this.onCancel,
//     this.showCancelButton = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       elevation: 5,
//       content: Container(
//         margin: const EdgeInsets.all(8.0),
//         padding: const EdgeInsets.all(20.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20.0),
//           color: Colors.white,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             SizedBox(height: 10.0),
//             Icon(
//               _getIcon(type),
//               color: _getColor(type),
//               size: 50,
//             ),
//             const SizedBox(height: 10.0),
//             Text(
//               title.isEmpty ? _getTitle(type) : title,
//               // style: ,
//               textAlign: TextAlign.center,
//             ),
//             Divider(),
//             Text(
//               message ?? 'An error occured!',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20.0),
//             SizedBox(
//               width: double.maxFinite,
//               child: Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: FlatButton(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Text(
//                         confirmText,
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       color: _getColor(type),
//                       textColor: Colors.white,
//                       onPressed: () {
//                         Navigator.pop(context);
//                         if (onConfirm != null) {
//                           onConfirm();
//                         }
//                       },
//                     ),
//                   ),
//                   if (showCancelButton)
//                     Expanded(
//                       child: FlatButton(
//                         padding: const EdgeInsets.all(5.0),
//                         child: Text(cancelText),
//                         onPressed: () {
//                           Navigator.pop(context);
//                           if (onCancel != null) {
//                             onCancel();
//                           }
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getColor(AlertType type) {
//     switch (type) {
//       case AlertType.warning:
//         return Colors.orange;
//       case AlertType.success:
//         return Colors.green;
//       case AlertType.error:
//         return Colors.red;
//       case AlertType.info:
//       default:
//         return Colors.blue;
//     }
//   }

//   IconData _getIcon(AlertType type) {
//     switch (type) {
//       case AlertType.warning:
//         return Icons.warning;
//       case AlertType.success:
//         return Icons.check_circle;
//       case AlertType.error:
//         return Icons.error;
//       case AlertType.info:
//       default:
//         return Icons.info_outline;
//     }
//   }

//   String _getTitle(AlertType type) {
//     switch (type) {
//       case AlertType.warning:
//         return 'Warning';
//       case AlertType.success:
//         return 'Success';
//       case AlertType.error:
//         return 'Oops!';
//       case AlertType.info:
//       default:
//         return '';
//     }
//   }
// }
