import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrayerCard extends StatefulWidget {
  final CombinePrayerStream prayerData;

  PrayerCard({this.prayerData});

  @override
  _PrayerCardState createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();
    var reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == widget.prayerData.prayer.id,
        orElse: () => null);

    if (reminder == null)
      return false;
    else
      return true;
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
                                  : Container()
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              hasReminder
                                  ? Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: AppColors.lightBlue3,
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
                                        '${tag.displayName.toUpperCase()}, ',
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
                                DateFormat('MM.dd.yyyy').format(
                                    widget.prayerData.prayer.modifiedOn),
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
    );
  }
}
