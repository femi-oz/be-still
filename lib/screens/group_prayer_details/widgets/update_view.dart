import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_rich_text/easy_rich_text.dart';

class UpdateView extends StatefulWidget {
  static const routeName = '/update';

  @override
  UpdateView(this.prayerData);
  final PrayerDataModel? prayerData;
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
      await Provider.of<PrayerProviderV2>(context, listen: false).getContacts();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }

    var updatedPhone = '';
    var updatedEmail = '';
    localContacts =
        Provider.of<PrayerProviderV2>(context, listen: false).localContacts;
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
    // final prayerData = Provider.of<GroupPrayerProvider>(context).currentPrayer;
    var updates = widget.prayerData?.updates ?? [];
    updates.sort((a, b) => (b.modifiedDate ?? DateTime.now())
        .compareTo(a.modifiedDate ?? DateTime.now()));
    updates =
        updates.where((element) => element.status != Status.deleted).toList();
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.prayerData?.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text(
                        widget.prayerData?.creatorName ?? '',
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                _buildDetail(
                    '',
                    updates[i].modifiedDate,
                    updates[i].description,
                    widget.prayerData?.tags ?? <TagModel>[],
                    context),
              _buildDetail(
                  'Initial Prayer | ',
                  widget.prayerData?.createdDate ?? DateTime.now(),
                  widget.prayerData?.description,
                  widget.prayerData?.tags ?? <TagModel>[],
                  context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(
      time, modifiedOn, description, List<TagModel> tags, context) {
    final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
                                if (tags[i].userId == _currentUserId)
                                  _openShareModal(
                                      context,
                                      tags[i].phoneNumber ?? '',
                                      tags[i].email ?? '',
                                      tags[i].contactIdentifier ?? '');
                              },
                            style: tags[i].userId == _currentUserId
                                ? AppTextStyles.regularText15.copyWith(
                                    color: AppColors.lightBlue2,
                                    decoration: TextDecoration.underline)
                                : AppTextStyles.regularText16b.copyWith(
                                    color: AppColors.prayerTextColor,
                                  ),
                          )
                      ],
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
