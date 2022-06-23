import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class ContactAccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Function? onConfirm;
  final Function? onCancel;
  const ContactAccessDialog({
    Key? key,
    this.title = '',
    this.message = 'An error occured!',
    this.confirmText = 'Ok',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (onCancel != null) {
                          onCancel!();
                        }
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onConfirm != null) {
                          onConfirm!();
                        }
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        // width: MediaQuery.of(context).size.width * .30,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: Text(
                            confirmText,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
