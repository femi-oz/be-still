import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  final CombinePrayerStream data;

  @override
  NoUpdateView(this.data);

  _emailLink(String payload, context) async {
    payload = payload == null ? '' : payload;
    final Email email = Email(
      body: '',
      recipients: [payload],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    Navigator.pop(context);
  }

  _textLink(String phoneNumber, context) async {
    String _result = await sendSMS(message: '', recipients: [phoneNumber])
        .catchError((onError) {
      print(onError);
    });
    Navigator.pop(context);
  }

  _openShareModal(BuildContext context, String phoneNumber, String email) {
    AlertDialog dialog = AlertDialog(
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
          height: MediaQuery.of(context).size.height * 0.35,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        'CONTACT METHOD',
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
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          'Please select a method to share this prayer.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regularText16b
                              .copyWith(color: AppColors.lightBlue4),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _emailLink(email, context);
                            },
                            child: Container(
                              height: 38.0,
                              width: MediaQuery.of(context).size.width * .22,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  'EMAIL',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _textLink(phoneNumber, context);
                            },
                            child: Container(
                              height: 38.0,
                              width: MediaQuery.of(context).size.width * .22,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  'TEXT',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 37),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 38.0,
                          width: MediaQuery.of(context).size.width * 0.71,
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.5),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              data.prayer.userId != _currentUser.id
                  ? Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        data.prayer.creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 30),
                    child: Row(
                      children: <Widget>[
                        Text(
                          DateFormat('hh:mma | MM.dd.yyyy')
                              .format(data.prayer.modifiedOn)
                              .toLowerCase(),
                          style: AppTextStyles.regularText18b
                              .copyWith(color: AppColors.prayeModeBorder),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.lightBlue4,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EasyRichText(
                        data.prayer.description,
                        defaultStyle: AppTextStyles.regularText16b.copyWith(
                          color: AppColors.prayerTextColor,
                        ),
                        textAlign: TextAlign.left,
                        patternList: [
                          for (var i = 0; i < data.tags.length; i++)
                            EasyRichTextPattern(
                                targetString: data.tags[i].displayName,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _openShareModal(
                                        context,
                                        data.tags[i].phoneNumber,
                                        data.tags[i].email);
                                  },
                                style: AppTextStyles.regularText15.copyWith(
                                    color: AppColors.lightBlue2,
                                    decoration: TextDecoration.underline))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
