import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

void showInfoModal(message, type, context) {
  final dialogContent = AlertDialog(
    actionsPadding: EdgeInsets.all(0),
    contentPadding: EdgeInsets.all(0),
    backgroundColor: AppColors.prayerCardBgColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: AppColors.darkBlue),
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
    content: Container(
      width: double.infinity,
      height: type == 'Group'
          ? MediaQuery.of(context).size.height * 0.4
          : MediaQuery.of(context).size.height * 0.35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10.0),
          Icon(
            Icons.error,
            color: AppColors.red,
            size: 50,
          ),
          SizedBox(height: 10.0),
          type == 'Group'
              ? Icon(
                  AppIcons.groups,
                  size: 50,
                  color: AppColors.lightBlue4,
                )
              : Container(),
          const SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText16b
                  .copyWith(color: AppColors.lightBlue4),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextButton(
              child: Text('OK',
                  style:
                      AppTextStyles.boldText16.copyWith(color: Colors.white)),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                    AppTextStyles.boldText16.copyWith(color: Colors.white)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(5.0)),
                elevation: MaterialStateProperty.all<double>(0.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    ),
  );
  showDialog(
      context: context, builder: (BuildContext context) => dialogContent);
}
