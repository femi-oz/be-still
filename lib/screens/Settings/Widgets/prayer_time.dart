import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/duration.model.dart';

import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrayerTimeSettings extends StatefulWidget {
  @override
  PrayerTimeSettings();
  _PrayerTimeSettingsState createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  @override
  void initState() {
    super.initState();
  }

  final prayerTimeText =
      'Be Still can remind you to pray at a specific time each day or on a regular schedule. Tap the "Add Reminder" button to create one or more prayer times. You will receive a short notification whenever you have scheduled a prayer time to start.';

  List<LookUpV2> songs = [
    LookUpV2(text: 'Evening Listening', value: 1),
    LookUpV2(text: 'Rock Jams', value: 2),
    LookUpV2(text: 'Prayer Time', value: 3),
    LookUpV2(text: 'Jason Station', value: 4),
    LookUpV2(text: 'New Hits', value: 5)
  ];

  double itemExtent = 30.0;
  bool showUpdateField = false;
  LocalNotificationDataModel reminder = LocalNotificationDataModel();

  _deletePrayerTime(
    int localNotificationId,
    String notificationId,
  ) async {
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .deleteLocalNotification(notificationId, localNotificationId);
      BeStilDialog.hideLoading(context);
      setState(() {});
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimeList =
        Provider.of<NotificationProviderV2>(context).prayerTimeNotifications;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            CustomSectionHeder('My Prayer Time'),
            SizedBox(height: 35.0),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  prayerTimeText,
                  style: AppTextStyles.regularText15
                      .copyWith(color: AppColors.prayerTextColor),
                )),
            SizedBox(height: 35.0),
            prayerTimeList.length > 0
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        ...prayerTimeList.map(
                          (data) => Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 15.0,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 10.0,
                                        ),
                                        height: 40.0,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.lightBlue6,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                data.frequency ?? '',
                                                style: AppTextStyles
                                                    .regularText15
                                                    .copyWith(
                                                        color: AppColors
                                                            .prayerTextColor),
                                              ),
                                            ),
                                            data.frequency == Frequency.weekly
                                                ? Container(
                                                    child: Text(
                                                      (LocalNotification
                                                              .daysOfWeek[(data
                                                                  .scheduleDate
                                                                  ?.weekday ??
                                                              0)])
                                                          .toString(),
                                                      style: AppTextStyles
                                                          .regularText15
                                                          .copyWith(
                                                        color: AppColors
                                                            .prayerTextColor,
                                                      ),
                                                    ),
                                                  )
                                                : data.frequency ==
                                                        Frequency.one_time
                                                    ? Container(
                                                        child: Text(
                                                          DateFormat('MM-dd-yy')
                                                              .format(data
                                                                      .scheduleDate ??
                                                                  DateTime
                                                                      .now()),
                                                          style: AppTextStyles
                                                              .regularText15
                                                              .copyWith(
                                                            color: AppColors
                                                                .prayerTextColor,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                            Row(
                                              children: [
                                                Text(
                                                  (data.scheduleDate?.hour ??
                                                          '')
                                                      .toString(),
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  ':',
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  '${data.scheduleDate?.minute == 0 ? '0' : ''}${(data.scheduleDate?.minute ?? '')}',
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  DateFormat('a').format(
                                                      data.scheduleDate ??
                                                          DateTime.now()),
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          reminder = data;
                                          showDialog(
                                            context: context,
                                            barrierColor: AppColors
                                                .detailBackgroundColor[1]
                                                .withOpacity(0.5),
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                insetPadding:
                                                    EdgeInsets.all(20),
                                                backgroundColor:
                                                    AppColors.prayerCardBgColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color:
                                                          AppColors.darkBlue),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 30),
                                                      child: ReminderPicker(
                                                        isGroup: false,
                                                        entityId: '',
                                                        type: NotificationType
                                                            .prayer_time,
                                                        reminder: data,
                                                        hideActionuttons: false,
                                                        onCancel: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(right: 5),
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            AppIcons.bestill_edit,
                                            size: 16,
                                            color: AppColors.lightBlue3,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _deletePrayerTime(
                                              data.localNotificationId ?? 0,
                                              data.id ?? '');
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(
                                            Icons.delete_forever,
                                            size: 22,
                                            color: AppColors.lightBlue3,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Row(
                    children: [
                      CustomButtonGroup(
                        title: 'ADD REMINDER',
                        onSelected: (_) => showDialog(
                          context: context,
                          barrierColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.5),
                          builder: (BuildContext context) {
                            return Dialog(
                              insetPadding: EdgeInsets.all(20),
                              backgroundColor: AppColors.prayerCardBgColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColors.darkBlue),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: ReminderPicker(
                                      isGroup: false,
                                      entityId: '',
                                      type: NotificationType.prayer_time,
                                      reminder: null,
                                      hideActionuttons: false,
                                      onCancel: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
