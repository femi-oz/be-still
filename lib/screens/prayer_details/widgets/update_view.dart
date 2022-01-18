import 'dart:io';

import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';

import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatefulWidget {
  static const routeName = '/update';

  @override
  UpdateView();

  @override
  _UpdateView createState() => _UpdateView();
}

class _UpdateView extends State<UpdateView> {
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
    try {
      await Provider.of<PrayerProvider>(context, listen: false).getContacts();
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
    var updatedPhone = '';
    var updatedEmail = '';
    localContacts =
        Provider.of<PrayerProvider>(context, listen: false).localContacts;
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
                              _emailLink(updatedEmail);
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
                              _textLink(updatedPhone);
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
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    bool isOwner = prayerData.prayer?.createdBy == userId;
    var updates = prayerData.updates;
    updates.sort((a, b) => (b.modifiedOn ?? DateTime.now())
        .compareTo(a.modifiedOn ?? DateTime.now()));
    updates = updates.where((element) => element.deleteStatus != -1).toList();
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              prayerData.prayer?.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text(
                        prayerData.prayer?.creatorName ?? '',
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.prayerPrimaryColor,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                _buildDetail('', updates[i].modifiedOn, updates[i].description,
                    prayerData.tags, context),
              _buildDetail(
                  'Initial Prayer | ',
                  prayerData.prayer?.createdOn ?? DateTime.now(),
                  prayerData.prayer?.description ?? '',
                  prayerData.tags,
                  context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(
      time, modifiedOn, description, List<PrayerTagModel>? tags, context) {
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    bool isOwner = prayerData.prayer?.createdBy == userId;
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      time,
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.prayerModeBorder),
                      overflow: TextOverflow.ellipsis,
                    ),
                    time != ''
                        ? Text(
                            DateFormat('MM.dd.yyyy')
                                .format(modifiedOn)
                                .toLowerCase(),
                            style: AppTextStyles.regularText18b
                                .copyWith(color: AppColors.prayerModeBorder),
                          )
                        : Text(
                            DateFormat('hh:mma | MM.dd.yyyy')
                                .format(modifiedOn)
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
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: isOwner
                        ? EasyRichText(
                            description,
                            defaultStyle: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                            patternList: [
                              for (var i = 0; i < (tags ?? []).length; i++)
                                EasyRichTextPattern(
                                    targetString:
                                        (tags?[i].displayName ?? '').trim(),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _openShareModal(
                                            context,
                                            tags?[i].phoneNumber ?? '',
                                            tags?[i].email ?? '',
                                            tags?[i].identifier ?? '');
                                      },
                                    style: AppTextStyles.regularText15.copyWith(
                                        color: AppColors.lightBlue2,
                                        decoration: TextDecoration.underline))
                            ],
                          )
                        : Text(
                            description,
                            style: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                          ),
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
