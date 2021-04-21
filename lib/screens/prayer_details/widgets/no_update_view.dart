import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:url_launcher/url_launcher.dart';

class NoUpdateView extends StatefulWidget {
  @override
  NoUpdateView();

  @override
  _NoUpdateViewState createState() => _NoUpdateViewState();
}

class _NoUpdateViewState extends State<NoUpdateView> {
  _emailLink([String email]) async {
    final Uri params = Uri(scheme: 'mailto', path: '', query: "");

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _textLink([String phoneNumber]) async {
    String _result = await sendSMS(message: '', recipients: [phoneNumber])
        .catchError((onError) {
      print(onError);
    });
    print(_result);

    // final uri =
    //     "sms:${isChurch ? _churchPhone : ''}${Platform.isIOS ? '&' : '?'}body=$_prayer \n\n ${updates != '' ? 'Comments  \n $updates \n\n' : ''}$_footerText";

    // if (await canLaunch(uri)) {
    //   await launch(uri);
    // } else {
    //   throw 'Could not launch $uri';
    // }
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
          height: MediaQuery.of(context).size.height * 0.2,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 5, right: 5),
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.cancel,
                    color: AppColors.red,
                    size: 20,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _emailLink(email);
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'EMAIL',
                                    style: TextStyle(
                                      color: AppColors.lightBlue4,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _textLink(phoneNumber);
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'SMS',
                                    style: TextStyle(
                                      color: AppColors.lightBlue4,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          prayerData.prayer.groupId != '0'
              ? Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    prayerData.prayer.creatorName,
                    style: AppTextStyles.boldText16.copyWith(
                      color: AppColors.lightBlue4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    DateFormat('hh:mma | MM.dd.yyyy')
                        .format(prayerData.prayer.createdOn)
                        .toLowerCase(),
                    style: AppTextStyles.regularText13.copyWith(
                      color: AppColors.lightBlue4,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Divider(
                  color: AppColors.lightBlue4,
                  thickness: 1,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: SingleChildScrollView(
                child: Center(
                  child: EasyRichText(
                    prayerData.prayer.description,
                    defaultStyle: AppTextStyles.regularText16b.copyWith(
                      color: AppColors.prayerTextColor,
                    ),
                    textAlign: TextAlign.left,
                    patternList: [
                      for (var i = 0; i < prayerData.tags.length; i++)
                        EasyRichTextPattern(
                            targetString: prayerData.tags[i].displayName,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _openShareModal(
                                    context,
                                    prayerData.tags[i].phoneNumber,
                                    prayerData.tags[i].email);
                              },
                            style: AppTextStyles.regularText15.copyWith(
                                color: AppColors.lightBlue2,
                                decoration: TextDecoration.underline))
                    ],
                  ),
                  // Text(
                  //   prayerData.prayer.description,
                  //   style: AppTextStyles.regularText18b.copyWith(
                  //     color: AppColors.prayerTextColor,
                  //   ),
                  //   textAlign: TextAlign.left,
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
