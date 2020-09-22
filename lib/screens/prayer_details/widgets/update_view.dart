import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final PrayerModel prayer;

  static const routeName = '/update';

  @override
  UpdateView(this.prayer);
  Widget build(BuildContext context) {
    final username = userData.singleWhere((u) => u.id == prayer.user).name;
    final _userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              prayer.user != _userProvider.user.id
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        username,
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              ...prayer.updates.map(
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
                                      .format(u.date),
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
                          ...u.tags
                              .map(
                                (t) => Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        t.toUpperCase(),
                                        style: TextStyle(
                                          color: context.prayerCardTags,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList()
                        ],
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: Center(
                            child: Text(
                              u.content,
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
                                DateFormat(' MM.dd.yyyy').format(prayer.date),
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
                        ...prayer.tags
                            .map(
                              (t) => Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  t.toUpperCase(),
                                  style: TextStyle(
                                    color: context.prayerCardTags,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    Container(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                        child: Center(
                          child: Text(
                            prayer.content,
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
