import 'package:be_still/data/group.data.dart';
import 'package:be_still/data/user.data.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  // final NotificationModel notification;

  // NotificationCard(this.notification);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressEnd: null,
      onTap: null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: context.prayerCardBorder,
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
            color: context.prayerCardBg,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: <Widget>[
                        //     notification.creator != ''
                        //         ? Text(
                        //             userData
                        //                 .singleWhere(
                        //                     (u) => u.id == notification.creator)
                        //                 .fullName
                        //                 .toUpperCase(),
                        //             style: TextStyle(
                        //               color: context.brightBlue,
                        //               fontWeight: FontWeight.w500,
                        //               fontSize: 10,
                        //             ),
                        //           )
                        //         : Container(),
                        //     Row(
                        //       children: <Widget>[
                        //         Text(
                        //           groupData
                        //               .singleWhere(
                        //                   (u) => u.id == notification.group)
                        //               .name
                        //               .toUpperCase(),
                        //           style: TextStyle(
                        //             color: context.prayerCardTags,
                        //             fontSize: 10,
                        //           ),
                        //         ),
                        //         Container(
                        //           margin: EdgeInsets.symmetric(
                        //             horizontal: 10,
                        //           ),
                        //           child: Text(
                        //             '|',
                        //             style: TextStyle(
                        //                 color: context.prayerCardBorder),
                        //           ),
                        //         ),
                        //         Text(
                        //           DateFormat('MM.dd.yyyy')
                        //               .format(notification.date),
                        //           style: TextStyle(
                        //             color: context.prayerCardPrayer,
                        //             fontSize: 10,
                        //           ),
                        //         ),
                        //       ],
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: context.prayerDivider,
                thickness: 0.5,
              ),
              Row(
                children: <Widget>[
                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.8,
                  //   child: Text(
                  //     notification.content.substring(0, 100),
                  //     style: TextStyle(
                  //       color: context.prayerCardPrayer,
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w300,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
