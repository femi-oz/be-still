import 'package:be_still/enums/status.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatefulWidget {
  final PrayerDataModel prayer;
  @override
  UpdateView(this.prayer);

  @override
  _UpdateViewState createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  Iterable<Contact> localContacts = [];

  _emailLink(String payload, context) async {
    final Email email = Email(
      body: '',
      recipients: [payload],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    Navigator.pop(context);
  }

  _textLink(String phoneNumber, context) async {
    await sendSMS(message: '', recipients: [phoneNumber]).catchError((onError) {
      print(onError);
    });
    Navigator.pop(context);
  }

  _openShareModal(BuildContext context, String phoneNumber, String email,
      String identifier) async {
    try {
      await Provider.of<PrayerProviderV2>(context, listen: false).getContacts();
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
                              _emailLink(updatedEmail, context);
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
                              _textLink(updatedPhone, context);
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
    var updates = widget.prayer.updates ?? <UpdateModel>[];
    updates.sort((a, b) => (b.modifiedDate ?? DateTime.now())
        .compareTo(a.modifiedDate ?? DateTime.now()));
    updates =
        updates.where((element) => element.status != Status.deleted).toList();

    final creatorName = Provider.of<UserProviderV2>(context)
        .getPrayerCreatorName(widget.prayer.createdBy ?? '');

    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.prayer.userId != FirebaseAuth.instance.currentUser?.uid
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                      .format(updates[i].createdDate ??
                                          DateTime.now())
                                      .toLowerCase(),
                                  style: AppTextStyles.regularText18b.copyWith(
                                      color: AppColors.prayerModeBorder),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.prayerModeBorder,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 20),
                        child: i == 0
                            ? Row(
                                children: [
                                  Flexible(
                                    child: EasyRichText(
                                      updates[i].description ?? '',
                                      defaultStyle:
                                          AppTextStyles.regularText16b.copyWith(
                                        color: AppColors.prayerTextColor,
                                      ),
                                      textAlign: TextAlign.left,
                                      patternList: [
                                        for (var i = 0;
                                            i <
                                                (widget.prayer.tags ??
                                                        <TagModel>[])
                                                    .length;
                                            i++)
                                          EasyRichTextPattern(
                                              targetString: widget
                                                  .prayer.tags?[i].displayName,
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _openShareModal(
                                                      context,
                                                      widget.prayer.tags?[i]
                                                              .phoneNumber ??
                                                          '',
                                                      widget.prayer.tags?[i]
                                                              .email ??
                                                          '',
                                                      widget.prayer.tags?[i]
                                                              .contactIdentifier ??
                                                          '');
                                                },
                                              style: AppTextStyles.regularText15
                                                  .copyWith(
                                                      color:
                                                          AppColors.lightBlue2,
                                                      decoration: TextDecoration
                                                          .underline))
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Flexible(
                                    child: EasyRichText(
                                      updates[i].description ?? '',
                                      defaultStyle:
                                          AppTextStyles.regularText16b.copyWith(
                                        color: AppColors.prayerTextColor,
                                      ),
                                      textAlign: TextAlign.left,
                                      patternList: [
                                        for (var i = 0;
                                            i <
                                                (widget.prayer.tags ??
                                                        <TagModel>[])
                                                    .length;
                                            i++)
                                          EasyRichTextPattern(
                                              targetString: widget
                                                  .prayer.tags?[i].displayName,
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _openShareModal(
                                                      context,
                                                      widget.prayer.tags?[i]
                                                              .phoneNumber ??
                                                          '',
                                                      widget.prayer.tags?[i]
                                                              .email ??
                                                          '',
                                                      widget.prayer.tags?[i]
                                                              .contactIdentifier ??
                                                          '');
                                                },
                                              style: AppTextStyles.regularText15
                                                  .copyWith(
                                                      color:
                                                          AppColors.lightBlue2,
                                                      decoration: TextDecoration
                                                          .underline))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              Container(
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
                                'Initial Prayer | ',
                                style: AppTextStyles.regularText18b.copyWith(
                                    color: AppColors.prayerModeBorder),
                              ),
                              Text(
                                DateFormat('MM.dd.yyyy').format(
                                    widget.prayer.createdDate ??
                                        DateTime.now()),
                                style: AppTextStyles.regularText18b.copyWith(
                                    color: AppColors.prayerModeBorder),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.prayerModeBorder,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Flexible(
                            child: EasyRichText(
                              widget.prayer.description ?? '',
                              defaultStyle:
                                  AppTextStyles.regularText16b.copyWith(
                                color: AppColors.prayerTextColor,
                              ),
                              textAlign: TextAlign.left,
                              patternList: [
                                for (var i = 0;
                                    i <
                                        (widget.prayer.tags ?? <TagModel>[])
                                            .length;
                                    i++)
                                  EasyRichTextPattern(
                                      targetString:
                                          widget.prayer.tags?[i].displayName,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _openShareModal(
                                              context,
                                              widget.prayer.tags?[i]
                                                      .phoneNumber ??
                                                  '',
                                              widget.prayer.tags?[i].email ??
                                                  '',
                                              widget.prayer.tags?[i]
                                                      .contactIdentifier ??
                                                  '');
                                        },
                                      style: AppTextStyles.regularText15
                                          .copyWith(
                                              color: AppColors.lightBlue2,
                                              decoration:
                                                  TextDecoration.underline))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
