import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_rich_text/easy_rich_text.dart';

class NoUpdateView extends StatefulWidget {
  @override
  NoUpdateView();

  @override
  _NoUpdateViewState createState() => _NoUpdateViewState();
}

class _NoUpdateViewState extends State<NoUpdateView> {
  Iterable<Contact> localContacts = [];

  _emailLink(String payload) async {
    final Email email = Email(
      body: '',
      recipients: [payload],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    Navigator.pop(context);
  }

  _textLink(String phoneNumber) async {
    await sendSMS(message: '', recipients: [phoneNumber]).catchError((onError) {
      print(onError);
    });
    Navigator.pop(context);
  }

  _openShareModal(BuildContext context, String phoneNumber, String email,
      String identifier) async {
    await Provider.of<GroupPrayerProvider>(context, listen: false)
        .getContacts();
    var updatedPhone = '';
    var updatedEmail = '';
    localContacts =
        Provider.of<GroupPrayerProvider>(context, listen: false).localContacts;
    var latestContact =
        localContacts.where((element) => element.identifier == identifier);

    for (var contact in latestContact) {
      final phoneNumber = (contact.phones ?? []).length > 0
          ? (contact.phones ?? []).toList()[0].value
          : null;
      final email = (contact.emails ?? []).length > 0
          ? (contact.emails ?? []).toList()[0].value
          : null;
      updatedPhone = phoneNumber ?? '';
      updatedEmail = email ?? '';
    }
    AlertDialog dialog = AlertDialog(
        actionsPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        backgroundColor: AppColors.prayerCardBgColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.darkBlue),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(children: [
              Container(
                  width: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text('CONTACT METHOD',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.lightBlue1,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.5))),
                        Flexible(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                    'Please select a method to share this prayer.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regularText16b
                                        .copyWith(
                                            color: AppColors.lightBlue4)))),
                        SizedBox(height: 20),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            width: double.infinity,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () {
                                        _emailLink(updatedEmail);
                                      },
                                      child: Container(
                                          height: 38.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .22,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            border: Border.all(
                                              color: AppColors.cardBorder,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                              child: Text('EMAIL',
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500))))),
                                  GestureDetector(
                                      onTap: () {
                                        _textLink(updatedPhone);
                                      },
                                      child: Container(
                                          height: 38.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .22,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            border: Border.all(
                                              color: AppColors.cardBorder,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                              child: Text('TEXT',
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)))))
                                ])),
                        SizedBox(height: 15),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 37),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    height: 38.0,
                                    width: MediaQuery.of(context).size.width *
                                        0.71,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withOpacity(0.5),
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text('CANCEL',
                                              style: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500))
                                        ]))))
                      ]))
            ])));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget build(BuildContext context) {
    final prayerData = Provider.of<GroupPrayerProvider>(context).currentPrayer;
    final _currentUser = Provider.of<UserProvider>(context).currentUser;

    return Container(
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
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
              Container(
                margin: EdgeInsets.only(right: 30),
                child: Row(
                  children: <Widget>[
                    Text(
                      DateFormat('hh:mma | MM.dd.yyyy')
                          .format(prayerData.prayer.createdOn)
                          .toLowerCase(),
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.prayerModeBorder),
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
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Flexible(
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                        child: SingleChildScrollView(
                            child: EasyRichText(prayerData.prayer.description,
                                defaultStyle:
                                    AppTextStyles.regularText16b.copyWith(
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
                                          prayerData.tags[i].email,
                                          prayerData.tags[i].identifier);
                                    },
                                  style: prayerData.tags[i].userId ==
                                          _currentUser.id
                                      ? AppTextStyles.regularText15.copyWith(
                                          color: AppColors.lightBlue2,
                                          decoration: TextDecoration.underline)
                                      : AppTextStyles.regularText16b.copyWith(
                                          color: AppColors.prayerTextColor,
                                        ),
                                )
                            ]))))
              ]))
        ]));
  }
}
