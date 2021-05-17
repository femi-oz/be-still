import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'dart:math' as math;

class PrayerCard extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final String timeago;
  final keyButton;

  PrayerCard(
      {@required this.prayerData, @required this.timeago, this.keyButton});

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

  void _unArchive() async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(widget.prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _onArchive() async {
    try {
      BeStilDialog.showLoading(context);
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      var reminders = Provider.of<NotificationProvider>(context, listen: false)
          .localNotifications
          .where((e) => e.type == NotificationType.reminder)
          .toList();
      reminders.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unSnoozePrayer() async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unSnoozePrayer(
          widget.prayerData.prayer.id,
          DateTime.now(),
          widget.prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _onMarkAsAnswered() async {
    try {
      BeStilDialog.showLoading(context);
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      var reminders = Provider.of<NotificationProvider>(context, listen: false)
          .localNotifications
          .where((e) => e.type == NotificationType.reminder)
          .toList();
      reminders.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unMarkAsAnswered() async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Widget _buildMenu() {
    return PrayerMenu(
        context, hasReminder, reminder, () => updateUI(), widget.prayerData);
  }

  updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    return Container(
      key: widget.keyButton,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 7.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
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
                                          style:
                                              AppTextStyles.boldText14.copyWith(
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
                                          size: 13,
                                        )
                                      : widget.prayerData.prayer.isAnswer
                                          ? Icon(
                                              AppIcons.bestill_answered,
                                              size: 12,
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
                                              onTap: () => showDialog(
                                                context: context,
                                                barrierColor: AppColors
                                                    .detailBackgroundColor[1]
                                                    .withOpacity(0.5),
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    insetPadding:
                                                        EdgeInsets.all(20),
                                                    backgroundColor: AppColors
                                                        .prayerCardBgColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: AppColors
                                                              .darkBlue),
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
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 30),
                                                          child: ReminderPicker(
                                                            type:
                                                                NotificationType
                                                                    .reminder,
                                                            hideActionuttons:
                                                                false,
                                                            onCancel: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            reminder: reminder,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children:
                                            widget.prayerData.tags.map((tag) {
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
                                                color:
                                                    AppColors.prayerTextColor),
                                          ),
                                        )
                                      : Container(),
                                  Text(
                                    widget.timeago,
                                    style: AppTextStyles.regularText13.copyWith(
                                        color: AppColors.prayerTextColor),
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
                      child: Text(
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
        ),
        actions: <Widget>[
          _buildSlideItem(
            Icons.build,
            'Options',
            () => showModalBottomSheet(
              context: context,
              barrierColor: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkModeEnabled
                  ? AppColors.backgroundColor[0].withOpacity(0.5)
                  : Color(0xFF021D3C).withOpacity(0.7),
              backgroundColor:
                  Provider.of<ThemeProvider>(context, listen: false)
                          .isDarkModeEnabled
                      ? AppColors.backgroundColor[0].withOpacity(0.5)
                      : Color(0xFF021D3C).withOpacity(0.7),
              isScrollControlled: true,
              builder: (BuildContext context) {
                return _buildMenu();
              },
            ),
          ),
        ],
        secondaryActions: <Widget>[
          _buildSlideItem(
            AppIcons.bestill_answered,
            widget.prayerData.prayer.isAnswer ? 'Unmark' : 'Answered',
            () => widget.prayerData.prayer.isAnswer
                ? _unMarkAsAnswered()
                : _onMarkAsAnswered(),
          ),
          _buildSlideItem(
            AppIcons.bestill_icons_bestill_archived_icon_revised_drk,
            widget.prayerData.userPrayer.isArchived ? 'Unarchive' : 'Archive',
            () => widget.prayerData.userPrayer.isArchived
                ? _unArchive()
                : _onArchive(),
          ),
          _buildSlideItem(
            AppIcons.bestill_snooze,
            widget.prayerData.userPrayer.isSnoozed ? 'Unsnooze' : 'Snooze',
            () => widget.prayerData.userPrayer.isSnoozed
                ? _unSnoozePrayer()
                : showModalBottomSheet(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    backgroundColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.9),
                    isScrollControlled: true,
                    builder: (BuildContext context) =>
                        SnoozePrayer(widget.prayerData),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideItem(IconData icon, String label, Function _onTap) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.prayerCardBgColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: Border.all(color: AppColors.cardBorder)),
      child: IconSlideAction(
        caption: label,
        color: Colors.transparent,
        iconWidget: Container(
          margin: const EdgeInsets.all(10.0),
          child: label == 'Options'
              ? Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: Icon(
                    icon,
                    color: AppColors.lightBlue3,
                    size: 18,
                  ),
                )
              : Icon(
                  icon,
                  color: AppColors.lightBlue3,
                  size: 18,
                ),
        ),
        foregroundColor: AppColors.lightBlue3,
        onTap: _onTap,
      ),
    );
  }
}
