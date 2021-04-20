import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class PrayerCard extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final String timeago;

  PrayerCard({@required this.prayerData, @required this.timeago});

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  LocalNotificationModel reminder;

  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == widget.prayerData.userPrayer.id,
        orElse: () => null);

    if (reminder == null)
      return false;
    else {
      return true;
    }
  }

  _emailLink([bool isChurch = false]) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    var name = _user.firstName;
    name = toBeginningOfSentenceCase(name);

    final Uri params = Uri(scheme: 'mailto', path: '', query: "");

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _textLink([bool isChurch = false]) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    var name = _user.firstName;
    name = toBeginningOfSentenceCase(name);

    String _result =
        await sendSMS(message: '', recipients: []).catchError((onError) {
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

  _openShareModal(BuildContext context) {
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
                              _emailLink(false);
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
                              _textLink(false);
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

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
          : '$selectedFrequency, $selectedHour:$selectedMinute $period';
      final title = '$selectedFrequency reminder to pray';
      final description = prayerData.prayer.description;
      final scheduleDate = LocalNotification.scheduleDate(
          int.parse(selectedHour),
          int.parse(selectedMinute),
          selectedDay,
          period);
      final payload = NotificationMessage(
          entityId: prayerData.userPrayer.id, type: NotificationType.prayer);
      await LocalNotification.setLocalNotification(
        context: context,
        title: title,
        description: description,
        scheduledDate: scheduleDate,
        payload: jsonEncode(payload.toJson()),
        frequency: selectedFrequency,
        localNotificationId: reminder.localNotificationId,
      );
      await storeNotification(
        notificationText,
        userId,
        title,
        description,
        selectedFrequency,
        scheduleDate,
        prayerData.userPrayer.id,
        selectedDay,
        period,
        selectedHour,
        selectedMinute,
      );
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  storeNotification(
    String notificationText,
    String userId,
    String title,
    String description,
    String frequency,
    tz.TZDateTime scheduledDate,
    String prayerid,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateLocalNotification(
      frequency,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
      reminder.id,
      userId,
      notificationText,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
          color: AppColors.prayerCardBgColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          border: Border.all(color: AppColors.cardBorder)),
      child: Container(
        margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.prayerCardBgColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            topLeft: Radius.circular(8),
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              widget.prayerData.prayer.userId != _user.id
                                  ? Text(
                                      widget.prayerData.prayer.creatorName,
                                      style: AppTextStyles.boldText14.copyWith(
                                        color: AppColors.lightBlue4,
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                width: 5,
                              ),
                              widget.prayerData.userPrayer.isFavorite
                                  ? Icon(
                                      Icons.favorite,
                                      color: AppColors.lightBlue3,
                                      size: 10,
                                    )
                                  : widget.prayerData.prayer.isAnswer
                                      ? Icon(
                                          AppIcons.bestill_answered,
                                          size: 10,
                                          color: AppColors.lightBlue3,
                                        )
                                      : Container()
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              hasReminder
                                  ? Row(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () => showModalBottomSheet(
                                            context: context,
                                            barrierColor: AppColors
                                                .detailBackgroundColor[1]
                                                .withOpacity(0.5),
                                            backgroundColor: AppColors
                                                .detailBackgroundColor[1]
                                                .withOpacity(0.9),
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return ReminderPicker(
                                                hideActionuttons: false,
                                                frequency: LocalNotification
                                                    .reminderInterval,
                                                reminderDays: LocalNotification
                                                    .reminderDays,
                                                onCancel: () =>
                                                    Navigator.of(context).pop(),
                                                onSave: (selectedFrequency,
                                                        selectedHour,
                                                        selectedMinute,
                                                        selectedDay,
                                                        period) =>
                                                    setNotification(
                                                        selectedHour,
                                                        selectedFrequency,
                                                        selectedMinute,
                                                        selectedDay,
                                                        period,
                                                        widget.prayerData),
                                                selectedDay: LocalNotification
                                                        .reminderDays
                                                        .indexOf(reminder
                                                            .selectedDay) +
                                                    1,
                                                selectedFrequency:
                                                    reminder.frequency,
                                                selectedHour: int.parse(
                                                    reminder.selectedHour),
                                                selectedMinute: int.parse(
                                                    reminder.selectedMinute),
                                                selectedPeriod: reminder.period,
                                              );
                                            },
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              AppIcons.bestill_reminder,
                                              size: 12,
                                              color: AppColors.lightBlue3,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '|',
                                            style: TextStyle(
                                              color: AppColors.lightBlue3,
                                              fontSize: 10,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: widget.prayerData.tags.map((tag) {
                                      return Text(
                                        ' ${tag.displayName}',
                                        style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 10,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              widget.prayerData.tags.length > 0
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        '|',
                                        style: TextStyle(
                                            color: AppColors.prayerTextColor),
                                      ),
                                    )
                                  : Container(),
                              Text(
                                widget.timeago,
                                style: AppTextStyles.regularText13
                                    .copyWith(color: AppColors.prayerTextColor),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              color: AppColors.divider,
              thickness: 0.5,
            ),
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child:
                      // EasyRichText(
                      //   widget.prayerData.prayer.description,
                      //   defaultStyle: AppTextStyles.regularText15
                      //       .copyWith(color: AppColors.prayerTextColor),
                      //   patternList: [
                      //     for (var i = 0; i < widget.prayerData.tags.length; i++)
                      //       EasyRichTextPattern(
                      //           targetString: widget.prayerData.tags[i].displayName,
                      //           recognizer: TapGestureRecognizer()
                      //             ..onTap = () {
                      //               _openShareModal(context);
                      //             },
                      //           style: AppTextStyles.regularText15.copyWith(
                      //               color: AppColors.lightBlue2,
                      //               decoration: TextDecoration.underline))
                      //   ],
                      // ),
                      Text(
                    widget.prayerData.prayer.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularText15
                        .copyWith(color: AppColors.prayerTextColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
