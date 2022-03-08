import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/group_prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class GroupPrayerCard extends StatefulWidget {
  final CombineGroupPrayerStream prayerData;
  final String timeago;

  GroupPrayerCard({
    required this.prayerData,
    required this.timeago,
  });

  @override
  _GroupPrayerCardState createState() => _GroupPrayerCardState();
}

class _GroupPrayerCardState extends State<GroupPrayerCard> {
  LocalNotificationModel reminder = LocalNotificationModel.defaultValue();
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

  void _sendPrayerNotification(String type) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .sendPrayerNotification(
            widget.prayerData.prayer?.id ?? '',
            widget.prayerData.groupPrayer?.id ?? '',
            type,
            widget.prayerData.groupPrayer?.groupId ?? '',
            context,
            widget.prayerData.prayer?.description ?? '');
  }

  void _followPrayer() async {
    BeStilDialog.showLoading(context);

    try {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final currentGroup =
          Provider.of<GroupProvider>(context, listen: false).currentGroup;
      final isFollowedByAdmin = (currentGroup.groupUsers ?? []).any((element) =>
          element.role == GroupUserRole.admin && element.userId == user.id);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .addToMyList(
        widget.prayerData.prayer?.id ?? '',
        user.id ?? '',
        currentGroup.group?.id ?? '',
        isFollowedByAdmin,
      );
      // await Provider.of<GroupPrayerProvider>(context, listen: false)
      //     .setFollowedPrayerByUserId(user.id ?? '');
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
      final _userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      final followedPrayer =
          Provider.of<GroupPrayerProvider>(context, listen: false)
              .followedPrayers
              .firstWhere(
                  (element) =>
                      element.prayerId == widget.prayerData.prayer?.id &&
                      element.createdBy == _userId,
                  orElse: () => FollowedPrayerModel.defaultValue());
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .removeFromMyList(
              followedPrayer.id ?? '', followedPrayer.userPrayerId ?? '');
      // await Provider.of<GroupPrayerProvider>(context, listen: false)
      //     .setFollowedPrayerByUserId(_userId ?? '');
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
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .unArchivePrayer(widget.prayerData.groupPrayer?.id ?? '',
              widget.prayerData.prayer?.id ?? '');
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
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.prayer?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      _sendPrayerNotification(NotificationType.archived_prayers);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.groupPrayer?.id ?? '',
              widget.prayerData.prayer?.id ?? '');
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

  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    return reminders.any(
      (reminder) => reminder.entityId == widget.prayerData.groupPrayer?.id,
    );
  }

  bool get isReminderActive {
    final reminders = Provider.of<NotificationProvider>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    LocalNotificationModel rem = reminders.firstWhere(
        (reminder) =>
            reminder.entityId == widget.prayerData.groupPrayer?.prayerId,
        orElse: () => LocalNotificationModel.defaultValue());
    if ((rem.id ?? '').isNotEmpty) {
      if (rem.frequency != Frequency.one_time) {
        return true;
      } else {
        if ((rem.scheduledDate ?? DateTime.now().subtract(Duration(hours: 1)))
            .isAfter(DateTime.now())) {
          return true;
        } else {
          Provider.of<NotificationProvider>(context).deleteLocalNotification(
              rem.id ?? '', rem.localNotificationId ?? 0);
          return false;
        }
      }
    } else {
      return false;
    }
  }

  bool get isFollowing {
    var isFollowing = Provider.of<GroupPrayerProvider>(context, listen: false)
        .followedPrayers
        .any((element) => element.prayerId == widget.prayerData.prayer?.id);
    return isFollowing;
  }

  setGroupPrayer(CombineGroupPrayerStream prayerData) async {
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
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    return Provider.of<GroupPrayerProvider>(context)
        .followedPrayers
        .any((element) {
      if (element.prayerId == widget.prayerData.prayer?.id &&
          element.createdBy == _user.id &&
          (element.isFollowedByAdmin ?? false)) {
        return true;
      } else {
        return false;
      }
    });
  }

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.groupPrayer?.prayerId &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      _sendPrayerNotification(NotificationType.answered_prayers);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(widget.prayerData.prayer?.id ?? '',
              widget.prayerData.groupPrayer?.id ?? '');
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
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(widget.prayerData.prayer?.id ?? '',
              widget.prayerData.groupPrayer?.id ?? '');
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

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    var tags = '';
    final eTags =
        (widget.prayerData.tags ?? []).map((e) => e.displayName).toSet();
    (widget.prayerData.tags ?? []).retainWhere(
        (x) => eTags.remove(x.displayName) && x.userId == _user.id);
    (widget.prayerData.tags ?? []).forEach((element) {
      tags += ' ' + (element.displayName ?? '');
    });

    bool isOwner = widget.prayerData.prayer?.createdBy == _user.id;
    final isActivePrayer =
        Provider.of<GroupPrayerProvider>(context).filterOption.toLowerCase() ==
            'active';
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
                                  widget.prayerData.prayer?.isAnswer ?? false
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
                                  widget.prayerData.groupPrayer?.isSnoozed ??
                                          false
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
                                    widget.prayerData.prayer?.creatorName ?? '',
                                    style: AppTextStyles.boldText14.copyWith(
                                      color: AppColors.lightBlue4,
                                    ),
                                  ),
                                  widget.prayerData.groupPrayer?.isFavorite ??
                                          false
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
                        widget.prayerData.prayer?.description ?? '',
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
            }, !isActivePrayer || isOwner),
          if (isAdmin || isOwner)
            _buildSlideItem(
                AppIcons.bestill_icons_bestill_archived_icon_revised_drk,
                widget.prayerData.groupPrayer?.isArchived ?? false
                    ? 'Unarchive'
                    : 'Archive',
                () => widget.prayerData.groupPrayer?.isArchived ?? false
                    ? _unArchive()
                    : _onArchive(),
                false),
          if ((isAdmin && isOwner) || (isOwner && !isAdmin))
            _buildSlideItem(
                AppIcons.bestill_answered,
                widget.prayerData.prayer?.isAnswer ?? false
                    ? 'Unmark'
                    : 'Answered',
                () => widget.prayerData.prayer?.isAnswer ?? false
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
        onTap: isDisabled ? () {} : _onTap,
      ),
    );
  }
}
