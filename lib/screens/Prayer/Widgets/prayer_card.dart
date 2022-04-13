import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'dart:math' as math;

class PrayerCard extends StatefulWidget {
  final PrayerDataModel prayer;
  final String timeago;

  PrayerCard({required this.prayer, required this.timeago});

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  // LocalNotificationModel reminder = LocalNotificationModel.defaultValue();
  final SlidableController slidableController = SlidableController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool get hasReminder {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    return reminders.any(
      (reminder) => reminder.prayerId == widget.prayer.id,
    );
  }

  bool get isReminderActive {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    LocalNotificationDataModel rem = reminders.firstWhere(
        (reminder) => reminder.prayerId == widget.prayer.id,
        orElse: () => LocalNotificationDataModel());
    if ((rem.id ?? '').isNotEmpty) {
      if (rem.frequency != Frequency.one_time) {
        return true;
      } else {
        if ((rem.scheduleDate ?? DateTime.now().subtract(Duration(hours: 1)))
            .isAfter(DateTime.now())) {
          return true;
        } else {
          Provider.of<NotificationProviderV2>(context).deleteLocalNotification(
              rem.id ?? '', rem.localNotificationId ?? 0);
          return false;
        }
      }
    } else {
      return false;
    }
  }

  // recurring
  // one time, check if the reminder is past

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayer.id ?? '', widget.prayer.followers ?? []);
      BeStilDialog.hideLoading(context);
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

  void _unMarkAsAnswered() async {
    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unMarkPrayerAsAnswered(widget.prayer.id ?? '');
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
  }

  void _unArchive() async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unArchivePrayer(widget.prayer.id ?? '',
              widget.prayer.followers ?? <FollowerModel>[], false);
      BeStilDialog.hideLoading(context);
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

  void _onArchive() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));

      await Provider.of<PrayerProviderV2>(context, listen: false).archivePrayer(
          widget.prayer.id ?? '',
          widget.prayer.followers ?? [],
          NotificationType.archived_prayers,
          widget.prayer.groupId ?? '',
          widget.prayer.description ?? '');
      BeStilDialog.hideLoading(context);
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

  void _unSnoozePrayer() async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unSnoozePrayer(
        widget.prayer.id ?? '',
      );
      BeStilDialog.hideLoading(context);
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

  Widget _buildMenu() {
    return PrayerMenu(context, hasReminder, _reminder(widget.prayer),
        () => updateUI(), widget.prayer);
  }

  LocalNotificationDataModel _reminder(PrayerDataModel? prayerData) {
    final reminders =
        Provider.of<NotificationProviderV2>(context, listen: false)
            .localNotifications;
    return reminders.firstWhere(
        (reminder) => reminder.prayerId == (prayerData?.id ?? ''),
        orElse: () => LocalNotificationDataModel());
  }

  updateUI() {
    setState(() {});
  }

  void _unFollowPrayer() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      final currentGroup =
          Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      final follower = (widget.prayer.followers ?? []).firstWhere(
          (e) => e.userId == FirebaseAuth.instance.currentUser?.uid,
          orElse: () => FollowerModel());
      final prayer = (user.prayers ?? []).firstWhere(
          (e) => e.prayerId == widget.prayer.id,
          orElse: () => FollowedPrayer());
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unFollowPrayer(
              widget.prayer.id ?? '',
              currentGroup.id ?? '',
              (user.prayers ?? []).map((e) => e.prayerId ?? '').toList(),
              prayer,
              follower);
      BeStilDialog.hideLoading(context);
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

  Future<void> _setCurrentPrayer() async {
    try {
      Provider.of<PrayerProviderV2>(context, listen: false)
          .getPrayer(prayerId: widget.prayer.id ?? '');
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

  bool get isAdmin {
    final group = Provider.of<GroupProviderV2>(context, listen: false)
        .userGroups
        .firstWhere((element) => element.id == widget.prayer.groupId);
    final isadmin = (group.users ?? []).any((element) =>
        element.role == GroupUserRole.admin &&
        element.userId == FirebaseAuth.instance.currentUser?.uid);
    return isadmin;
  }

  @override
  Widget build(BuildContext context) {
    final _user = FirebaseAuth.instance.currentUser?.uid;
    final creatorName = Provider.of<UserProviderV2>(context)
        .getPrayerCreatorName(widget.prayer.createdBy ?? '');
    bool isOwner = widget.prayer.createdBy == _user;
    List<String> tags =
        (widget.prayer.tags ?? []).map((e) => e.displayName ?? '').toList();

    bool isGroupPrayer = widget.prayer.isGroup ?? false;

    bool showOption = false;
    if (isGroupPrayer && isAdmin) {
      showOption = true;
    } else if (isGroupPrayer && !isAdmin) {
      showOption = false;
    } else if (!isGroupPrayer) {
      showOption = true;
    }

    bool isFollowing = false;
    isFollowing = (widget.prayer.followers ?? []).any(
        (element) => element.userId == FirebaseAuth.instance.currentUser?.uid);

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
                                  widget.prayer.isAnswered ?? false
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
                                  widget.prayer.status == Status.snoozed
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
                                  hasReminder && isReminderActive
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
                                                          entityId:
                                                              (widget.prayer)
                                                                      .id ??
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
                                                          reminder: _reminder(
                                                              widget.prayer),
                                                          prayerData:
                                                              widget.prayer,
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
                                  widget.prayer.userId != _user
                                      ? Text(
                                          creatorName,
                                          style:
                                              AppTextStyles.boldText14.copyWith(
                                            color: AppColors.lightBlue4,
                                          ),
                                        )
                                      : Container(),
                                  ((widget.prayer).isFavorite ?? false)
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
                                      child: (widget.prayer.tags ??
                                                      <TagModel>[])
                                                  .length >
                                              0
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
                                                        tags.join(', '),
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
                        widget.prayer.description ?? '',
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
              barrierColor: Provider.of<ThemeProviderV2>(context, listen: false)
                      .isDarkModeEnabled
                  ? AppColors.backgroundColor[0].withOpacity(0.5)
                  : Color(0xFF021D3C).withOpacity(0.7),
              backgroundColor:
                  Provider.of<ThemeProviderV2>(context, listen: false)
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
          if (isFollowing)
            _buildSlideItem(Icons.star, 'Unfollow', () async {
              _unFollowPrayer();
            }, false),
          if (showOption)
            _buildSlideItem(
                AppIcons.bestill_icons_bestill_archived_icon_revised_drk,
                widget.prayer.status == Status.archived
                    ? 'Unarchive'
                    : 'Archive',
                () => widget.prayer.status == Status.archived
                    ? _unArchive()
                    : _onArchive(),
                !isOwner && !isAdmin),
          if (showOption)
            _buildSlideItem(
                AppIcons.bestill_answered,
                widget.prayer.isAnswered ?? false ? 'Unmark' : 'Answered',
                () => widget.prayer.isAnswered ?? false
                    ? _unMarkAsAnswered()
                    : _onMarkAsAnswered(),
                !isOwner && !isAdmin),
          if (!isGroupPrayer)
            widget.prayer.status == Status.archived ||
                    (widget.prayer.isAnswered == true)
                ? _buildSlideItem(
                    AppIcons.bestill_snooze, 'Snooze', () => null, true)
                : _buildSlideItem(
                    AppIcons.bestill_snooze,
                    widget.prayer.status == Status.snoozed
                        ? 'Unsnooze'
                        : 'Snooze',
                    () => widget.prayer.status == Status.snoozed
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
                                        child: SnoozePrayer(widget.prayer,
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
      IconData icon, String label, Function() _onTap, bool isDisabled) {
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
                    color: Provider.of<ThemeProviderV2>(context, listen: false)
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
                  color: Provider.of<ThemeProviderV2>(context, listen: false)
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
        foregroundColor: Provider.of<ThemeProviderV2>(context, listen: false)
                .isDarkModeEnabled
            ? isDisabled
                ? AppColors.white.withOpacity(0.4)
                : AppColors.white
            : isDisabled
                ? AppColors.lightBlue3.withOpacity(0.4)
                : AppColors.lightBlue3,
        onTap: isDisabled ? () {} : _onTap,
      ),
    );
  }
}
