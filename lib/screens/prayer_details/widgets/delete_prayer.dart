import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';

import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeletePrayer extends StatefulWidget {
  final CombinePrayerStream prayerData;
  @override
  DeletePrayer(this.prayerData);

  @override
  _DeletePrayerState createState() => _DeletePrayerState();
}

class _DeletePrayerState extends State<DeletePrayer> {
  BuildContext bcontext;

  void _onUnArchive() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(widget.prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
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
      BeStilDialog.showLoading(
        bcontext,
      );
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
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

  _onDelete() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .deletePrayer(widget.prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
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

  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: Text(
              'Are you sure you want to delete this prayer?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightBlue4,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          !widget.prayerData.prayer.isAnswer &&
                  !widget.prayerData.userPrayer.isArchived
              ? GestureDetector(
                  onTap: _onArchive,
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    margin: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.5),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'ARCHIVE',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _onUnArchive,
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    margin: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.5),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'UNARCHIVE',
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
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
                GestureDetector(
                  onTap: _onDelete,
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
                    decoration: BoxDecoration(
                      color: Colors.blue,
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
                          'DELETE',
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
