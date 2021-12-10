import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
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
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'dart:math' as math;

class PrayerCard extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final String timeago;

  PrayerCard({@required this.prayerData, @required this.timeago});

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  LocalNotificationModel reminder;
  final SlidableController slidableController = SlidableController();
  FollowedPrayerModel followedPrayer;

  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context)
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

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.userPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.userPrayer.id);
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unMarkAsAnswered() async {
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.userPrayer.id);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unArchive() async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unArchivePrayer(
          widget.prayerData.userPrayer.id, widget.prayerData.prayer.id);
      BeStilDialog.hideLoading(context);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _onArchive() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.userPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));

      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.userPrayer.id);
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
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
      BeStilDialog.hideLoading(context);
    } catch (e, s) {
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

  void _unFollowPrayer(followedPrayerId, userPrayerId) async {
    // BeStilDialog.showLoading(context);

    try {
      BeStilDialog.hideLoading(context);

      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .removeFromMyList(followedPrayerId, userPrayerId);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _setCurrentPrayer() async {
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(widget.prayerData.userPrayer.id);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    bool isOwner = widget.prayerData.prayer.createdBy == _user.id;
    var tags = '';
    final eTags = widget.prayerData.tags.map((e) => e.displayName).toSet();
    widget.prayerData.tags.retainWhere((x) => eTags.remove(x.displayName));
    widget.prayerData.tags.forEach((element) {
      tags += ' ' + element.displayName;
    });

    bool isGroupPrayer = widget.prayerData.prayer.isGroup;

    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 7.0),
      child: Slidable(
        controller: slidableController,
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
                                  widget.prayerData.prayer.isAnswer
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5, right: 8),
                                          child: Icon(
                                            AppIcons.bestill_answered,
                                            size: 12,
                                            color: AppColors.lightBlue3,
                                          ),
                                        )
                                      : SizedBox(),
                                  widget.prayerData.userPrayer.isSnoozed
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5, right: 8),
                                          child: Icon(
                                            AppIcons.snooze,
                                            size: 14,
                                            color: AppColors.lightBlue3,
                                          ),
                                        )
                                      : SizedBox(),
                                  hasReminder
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: InkWell(
                                            onTap: () => showDialog(
                                              context: context,
                                              barrierColor: AppColors
                                                  .detailBackgroundColor[1]
                                                  .withOpacity(0.5),
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding:
                                                      EdgeInsets.all(20),
                                                  backgroundColor: AppColors
                                                      .prayerCardBgColor,
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 30),
                                                        child: ReminderPicker(
                                                          isGroup: false,
                                                          entityId: widget
                                                                  .prayerData
                                                                  ?.userPrayer
                                                                  ?.id ??
                                                              '',
                                                          type: NotificationType
                                                              .reminder,
                                                          hideActionuttons:
                                                              false,
                                                          popTwice: false,
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
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5, right: 8),
                                              child: Icon(
                                                AppIcons.bestill_reminder,
                                                size: 12,
                                                color: AppColors.lightBlue3,
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  widget.prayerData.prayer.userId != _user?.id
                                      ? Text(
                                          widget.prayerData.prayer.creatorName,
                                          style:
                                              AppTextStyles.boldText14.copyWith(
                                            color: AppColors.lightBlue4,
                                          ),
                                        )
                                      : Container(),
                                  widget.prayerData.userPrayer.isFavorite &&
                                          !widget
                                              .prayerData.userPrayer.isSnoozed
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3, bottom: 3, right: 8),
                                          child: Icon(
                                            Icons.favorite,
                                            color: AppColors.lightBlue3,
                                            size: 14,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: widget.prayerData.tags.length > 0
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    reverse: true,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 3),
                                                      child: Text(
                                                        tags,
                                                        style: TextStyle(
                                                          color: AppColors.red,
                                                          fontSize: 10,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
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
                                                        color: AppColors
                                                            .prayerTextColor),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container(),
                                    ),
                                    Container(
                                      child: Text(
                                        widget.timeago,
                                        style: AppTextStyles.regularText13
                                            .copyWith(
                                                color:
                                                    AppColors.prayerTextColor),
                                      ),
                                    ),
                                  ],
                                ),
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
        closeOnScroll: true,
        actions: <Widget>[
          _buildSlideItem(Icons.build, 'Options', () async {
            await _setCurrentPrayer();

            showModalBottomSheet(
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
            );
          }, false)
        ],
        secondaryActions: <Widget>[
          if (isGroupPrayer)
            _buildSlideItem(Icons.star, 'UnFollow', () async {
              BeStilDialog.showLoading(context);
              await Provider.of<GroupPrayerProvider>(context, listen: false)
                  .setFollowedPrayer(widget.prayerData.prayer.id);
              Future.delayed(Duration(seconds: 2), () {
                followedPrayer = Provider.of<GroupPrayerProvider>(context,
                        listen: false)
                    .followedPrayers
                    .firstWhere(
                        (element) =>
                            element.prayerId == widget.prayerData.prayer.id &&
                            element.createdBy == _user.id,
                        orElse: () => null);
                _unFollowPrayer(followedPrayer.id, followedPrayer.userPrayerId);
              });
            }, false),
          if (!isGroupPrayer)
            _buildSlideItem(
                AppIcons.bestill_icons_bestill_archived_icon_revised_drk,
                widget.prayerData.userPrayer.isArchived
                    ? 'Unarchive'
                    : 'Archive',
                () => widget.prayerData.userPrayer.isArchived
                    ? _unArchive()
                    : _onArchive(),
                !isOwner),
          if (!isGroupPrayer)
            _buildSlideItem(
                AppIcons.bestill_answered,
                widget.prayerData.prayer.isAnswer ? 'Unmark' : 'Answered',
                () => widget.prayerData.prayer.isAnswer
                    ? _unMarkAsAnswered()
                    : _onMarkAsAnswered(),
                !isOwner),
          if (!isGroupPrayer)
            widget.prayerData.userPrayer.isArchived ||
                    widget.prayerData.prayer.isAnswer
                ? _buildSlideItem(
                    AppIcons.bestill_snooze, 'Snooze', () => null, true)
                : _buildSlideItem(
                    AppIcons.bestill_snooze,
                    widget.prayerData.userPrayer.isSnoozed
                        ? 'Unsnooze'
                        : 'Snooze',
                    () => widget.prayerData.userPrayer.isSnoozed
                        ? _unSnoozePrayer()
                        : showDialog(
                            context: context,
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
                                        child: SnoozePrayer(widget.prayerData,
                                            popTwice: !isOwner)),
                                  ],
                                ),
                              );
                            },
                          ),
                    !isOwner),
        ],
      ),
    );
  }

  Widget _buildSlideItem(
      IconData icon, String label, Function _onTap, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.prayerCardBgColor,
          border: Border.all(color: AppColors.slideBorder)),
      child: IconSlideAction(
        closeOnTap: true,
        caption: label,
        color: Colors.transparent,
        iconWidget: Container(
          margin: const EdgeInsets.all(10.0),
          child: label == 'Options'
              ? Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: Icon(
                    icon,
                    color: Provider.of<ThemeProvider>(context, listen: false)
                            .isDarkModeEnabled
                        ? isDisabled
                            ? AppColors.white.withOpacity(0.4)
                            : AppColors.white
                        : isDisabled
                            ? AppColors.lightBlue3.withOpacity(0.4)
                            : AppColors.lightBlue3,
                    size: 18,
                  ),
                )
              : Icon(
                  icon,
                  color: Provider.of<ThemeProvider>(context, listen: false)
                          .isDarkModeEnabled
                      ? isDisabled
                          ? AppColors.white.withOpacity(0.4)
                          : AppColors.white
                      : isDisabled
                          ? AppColors.lightBlue3.withOpacity(0.4)
                          : AppColors.lightBlue3,
                  size: 18,
                ),
        ),
        foregroundColor:
            Provider.of<ThemeProvider>(context, listen: false).isDarkModeEnabled
                ? isDisabled
                    ? AppColors.white.withOpacity(0.4)
                    : AppColors.white
                : isDisabled
                    ? AppColors.lightBlue3.withOpacity(0.4)
                    : AppColors.lightBlue3,
        onTap: isDisabled ? null : _onTap,
      ),
    );
  }
}
