import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final PrayerModel prayer;
  final List<PrayerUpdateModel> updates;

  static const routeName = '/update';

  @override
  UpdateView(this.prayer, this.updates);
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              prayer.userId != _currentUser.id
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        prayer.createdBy,
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              ...updates.map(
                (u) => Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 30),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  DateFormat('hh:mma | MM.dd.yyyy')
                                      .format(u.createdOn),
                                  style: TextStyle(
                                      color: context.dimBlue,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: context.prayerDetailsCardBorder,
                              thickness: 1,
                            ),
                          ),
                          // TODO
                          // ...u.tags
                          //     .map(
                          //       (t) => Container(
                          //         margin: EdgeInsets.only(left: 10),
                          //         child: Row(
                          //           children: <Widget>[
                          //             Text(
                          //               t.toUpperCase(),
                          //               style: TextStyle(
                          //                 color: context.prayerCardTags,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     )
                          //     .toList()
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 300,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: Center(
                            child: Text(
                              u.description,
                              style: TextStyle(
                                color: context.inputFieldText,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                height: 2,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 30),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Initial Prayer Request |',
                                style: TextStyle(
                                    color: context.dimBlue,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat(' MM.dd.yyyy')
                                    .format(prayer.createdOn),
                                style: TextStyle(
                                    color: context.dimBlue,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: context.prayerDetailsCardBorder,
                            thickness: 1,
                          ),
                        ),
                        // TODO
                        // ...prayer.tags
                        //     .map(
                        //       (t) => Container(
                        //         margin: EdgeInsets.only(left: 10),
                        //         child: Text(
                        //           t.toUpperCase(),
                        //           style: TextStyle(
                        //             color: context.prayerCardTags,
                        //           ),
                        //         ),
                        //       ),
                        //     )
                        //     .toList(),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 200,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                        child: Center(
                          child: Text(
                            prayer.description,
                            style: TextStyle(
                              color: context.inputFieldText,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 2,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
