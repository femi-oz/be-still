import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/group_prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class GroupPrayerCard extends StatefulWidget {
  final PrayerDataModel prayerData;
  final String timeago;

  GroupPrayerCard({
    required this.prayerData,
    required this.timeago,
  });

  @override
  _GroupPrayerCardState createState() => _GroupPrayerCardState();
}

class _GroupPrayerCardState extends State<GroupPrayerCard> {
  LocalNotificationDataModel reminder = LocalNotificationDataModel();
  final SlidableController slidableController = SlidableController();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {} on HttpException catch (e, s) {
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
    });

    super.initState();
  }

  // void _sendPrayerNotification(String type) async {
  //   await Provider.of<NotificationProviderV2>(context, listen: false)
  //       .sendPrayerNotification(
  //           widget.prayerData.prayer?.id ?? '',
  //           widget.prayerData.groupPrayer?.id ?? '',
  //           type,
  //           widget.prayerData.groupPrayer?.groupId ?? '',
  //           context,
  //           widget.prayerData.prayer?.description ?? '');
  // }

  void _followPrayer() async {
    BeStilDialog.showLoading(context);

    try {
      final currentGroup =
          Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await Provider.of<PrayerProviderV2>(context, listen: false).followPrayer(
          widget.prayerData.id ?? '',
          currentGroup.id ?? '',
          (user.prayers ?? []).map((e) => e.prayerId ?? '').toList());

      BeStilDialog.hideLoading(context);
      AppController appController = Get.find();
      appController.setCurrentPage(8, true, 0);
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

  void _unFollowPrayer() async {
    BeStilDialog.showLoading(context);

    try {
      final currentGroup =
          Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      final follower = (widget.prayerData.followers ?? []).firstWhere(
          (e) => e.userId == FirebaseAuth.instance.currentUser?.uid);
      final prayer = (user.prayers ?? [])
          .firstWhere((e) => e.prayerId == widget.prayerData.id);
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unFollowPrayer(
              widget.prayerData.id ?? '',
              currentGroup.id ?? '',
              (user.prayers ?? []).map((e) => e.prayerId ?? '').toList(),
              prayer,
              follower);
      BeStilDialog.hideLoading(context);
      AppController appController = Get.find();
      appController.setCurrentPage(8, true, 0);
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

  void _unArchive() async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unArchivePrayer(widget.prayerData.id ?? '',
              widget.prayerData.followers ?? <FollowerModel>[], isAdmin);
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
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .getLocalNotificationsByPrayerId(widget.prayerData.id ?? '');
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));

      await Provider.of<PrayerProviderV2>(context, listen: false).archivePrayer(
          widget.prayerData.id ?? '',
          widget.prayerData.followers ?? [],
          NotificationType.archived_prayers,
          widget.prayerData.groupId ?? '',
          widget.prayerData.description ?? '');

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

  bool get hasReminder {
    var reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    return reminders.any(
      (reminder) => reminder.prayerId == widget.prayerData.id,
    );
  }

  bool get isReminderActive {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    LocalNotificationDataModel rem = reminders.firstWhere(
        (reminder) => reminder.prayerId == widget.prayerData.id,
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

  bool get isFollowing {
    var isFollowing = Provider.of<PrayerProviderV2>(context, listen: false)
        .followedPrayers
        .any((element) => element.id == widget.prayerData.id);
    return isFollowing;
  }

  setGroupPrayer(PrayerDataModel prayerData) async {
    try {
      // await Provider.of<GroupPrayerProvider>(context, listen: false)
      //     .setFollowedPrayer(prayerData.prayer?.id ?? '');
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
    return PrayerGroupMenu(
        context, hasReminder, reminder, () => updateUI(), widget.prayerData);
  }

  updateUI() {
    setState(() {});
  }

  bool get isAdmin {
    final group =
        Provider.of<GroupProviderV2>(context, listen: false).currentGroup;

    return (group.users ?? []).any((e) =>
        e.role == GroupUserRole.admin &&
        e.userId == FirebaseAuth.instance.currentUser?.uid);
  }

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      final notifications =
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .getLocalNotificationsByPrayerId(widget.prayerData.id ?? '');

      for (var e in notifications) {
        await Provider.of<NotificationProviderV2>(context, listen: false)
            .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0);
      }
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .markPrayerAsAnswered(
        widget.prayerData.id ?? '',
        widget.prayerData.followers ?? [],
        NotificationType.answered_prayers,
        widget.prayerData.groupId ?? '',
        widget.prayerData.description ?? '',
      );
      // _deleteFollowedPrayers();

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
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unMarkPrayerAsAnswered(
        widget.prayerData.id ?? '',
      );
      BeStilDialog.hideLoading(context);
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

  Future<void> _sendPrayerNotification(String type) async {
    await Provider.of<NotificationProviderV2>(context, listen: false)
        .sendPrayerNotification(
            widget.prayerData.id ?? '',
            type,
            widget.prayerData.groupId ?? '',
            widget.prayerData.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final _userId = FirebaseAuth.instance.currentUser?.uid;
    final tags =
        (widget.prayerData.tags ?? []).map((e) => e.displayName ?? '').toList();

    bool isOwner = widget.prayerData.createdBy == _userId;
    final isActivePrayer = Provider.of<PrayerProviderV2>(context)
            .groupFilterOption
            .toLowerCase() ==
        Status.active.toLowerCase();
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
                                  widget.prayerData.isAnswered ?? false
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
                                  widget.prayerData.status == Status.snoozed
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
                                  // hasReminder && isReminderActive
                                  //     ? Padding(
                                  //         padding:
                                  //             const EdgeInsets.only(right: 5.0),
                                  //         child: InkWell(
                                  //           onTap: () => showDialog(
                                  //             context: context,
                                  //             barrierColor: AppColors
                                  //                 .detailBackgroundColor[1]
                                  //                 .withOpacity(0.5),
                                  //             builder: (BuildContext context) {
                                  //               return Dialog(
                                  //                 insetPadding:
                                  //                     EdgeInsets.all(20),
                                  //                 backgroundColor: AppColors
                                  //                     .prayerCardBgColor,
                                  //                 shape: RoundedRectangleBorder(
                                  //                   side: BorderSide(
                                  //                       color:
                                  //                           AppColors.darkBlue),
                                  //                   borderRadius:
                                  //                       BorderRadius.all(
                                  //                     Radius.circular(10.0),
                                  //                   ),
                                  //                 ),
                                  //                 child: Column(
                                  //                   mainAxisSize:
                                  //                       MainAxisSize.min,
                                  //                   children: [
                                  //                     Padding(
                                  //                       padding:
                                  //                           const EdgeInsets
                                  //                                   .symmetric(
                                  //                               vertical: 30),
                                  //                       child: ReminderPicker(
                                  //                         entityId: (widget
                                  //                                         .prayerData
                                  //                                         .groupPrayer ??
                                  //                                     GroupPrayerModel
                                  //                                         .defaultValue())
                                  //                                 .id ??
                                  //                             '',
                                  //                         isGroup: true,
                                  //                         type: NotificationType
                                  //                             .reminder,
                                  //                         hideActionuttons:
                                  //                             false,
                                  //                         popTwice: false,
                                  //                         onCancel: () =>
                                  //                             Navigator.of(
                                  //                                     context)
                                  //                                 .pop(),
                                  //                         reminder: reminder,
                                  //                       ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               );
                                  //             },
                                  //           ),
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.only(
                                  //                 top: 5, bottom: 5, right: 8),
                                  //             child: Icon(
                                  //               AppIcons.bestill_reminder,
                                  //               size: 12,
                                  //               color: AppColors.lightBlue3,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : SizedBox(),
                                  Text(
                                    widget.prayerData.creatorName ?? '',
                                    style: AppTextStyles.boldText14.copyWith(
                                      color: AppColors.lightBlue4,
                                    ),
                                  ),
                                  widget.prayerData.isFavorite ?? false
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
                                      child: (widget.prayerData.tags ?? [])
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
                        widget.prayerData.description ?? '',
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
            // _setCurrentPrayer();
            showModalBottomSheet(
                context: context,
                barrierColor:
                    Provider.of<ThemeProviderV2>(context, listen: false)
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
                });
          }, false)
        ],
        secondaryActions: <Widget>[
          // if ((!isOwner && isAdmin) || (!isOwner && !isAdmin))
          if (!isOwner)
            _buildSlideItem(Icons.star, isFollowing ? 'Unfollow' : 'Follow',
                () async {
              // _setCurrentPrayer();
              setState(() {
                if (isFollowing) {
                  _unFollowPrayer();
                } else {
                  _followPrayer();
                }
              });
            }, !isActivePrayer),
          if (isOwner)
            _buildSlideItem(
                AppIcons.bestill_icons_bestill_archived_icon_revised_drk,
                widget.prayerData.status == Status.archived
                    ? 'Unarchive'
                    : 'Archive',
                () => widget.prayerData.status == Status.archived
                    ? _unArchive()
                    : _onArchive(),
                false),
          if ((isAdmin && isOwner) || (isOwner && !isAdmin))
            _buildSlideItem(
                AppIcons.bestill_answered,
                widget.prayerData.isAnswered ?? false ? 'Unmark' : 'Answered',
                () => widget.prayerData.isAnswered ?? false
                    ? _unMarkAsAnswered()
                    : _onMarkAsAnswered(),
                false),
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
