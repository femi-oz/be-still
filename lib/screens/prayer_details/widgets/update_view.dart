import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/utils/app_icons.dart';

import 'package:be_still/utils/essentials.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateView extends StatelessWidget {
  // final PrayerModel prayer;
  // final List<PrayerUpdateModel> updates;

  static const routeName = '/update';

  @override
  UpdateView();
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
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      AppIcons.bestill_close,
                      color: AppColors.grey4,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        'SELECT CONTACT METHOD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.lightBlue1,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.5,
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
                              _emailLink(email);
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .20,
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
                              _textLink(phoneNumber);
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .20,
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
                                  'SMS',
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
    final updates = prayerData.updates;
    updates.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              prayerData.prayer.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text(
                        prayerData.prayer.creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.prayerPrimaryColor,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                _buildDetail(
                    DateFormat('hh:mma |')
                        .format(updates[i].modifiedOn)
                        .toLowerCase(),
                    updates[i].modifiedOn,
                    updates[i].description,
                    prayerData.tags,
                    context),
              _buildDetail('Initial Prayer |', prayerData.prayer.createdOn,
                  prayerData.prayer.description, prayerData.tags, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(time, modifiedOn, description, tags, context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 30),
                child: Row(
                  children: <Widget>[
                    Text(
                      DateFormat('hh:mma | MM.dd.yyyy')
                          .format(modifiedOn)
                          .toLowerCase(),
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.prayeModeBorder),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Divider(
                    color: AppColors.lightBlue4,
                    thickness: 1,
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: EasyRichText(
                      description,
                      defaultStyle: AppTextStyles.regularText16b
                          .copyWith(color: AppColors.prayerTextColor),
                      patternList: [
                        for (var i = 0; i < tags.length; i++)
                          EasyRichTextPattern(
                              targetString: tags[i].displayName,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _openShareModal(context, tags[i].phoneNumber,
                                      tags[i].email);
                                },
                              style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.lightBlue2,
                                  decoration: TextDecoration.underline))
                      ],
                    ),

                    // Text(
                    //   description,
                    //   style: AppTextStyles.regularText18b.copyWith(
                    //     color: AppColors.prayerTextColor,
                    //   ),
                    //   textAlign: TextAlign.left,
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
