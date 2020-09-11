import 'package:be_still/Data/user.data.dart';
import 'package:be_still/Models/prayer.model.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final PrayerModel prayer;

  @override
  UpdateView(this.prayer);
  Widget build(BuildContext context) {
    final username = userData.singleWhere((u) => u.id == prayer.user).name;
    final _app = Provider.of<AppProvider>(context);
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              prayer.user != _app.user.id
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        username,
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              ...prayer.updates.map(
                (u) => Container(
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
                              vertical: 100.0, horizontal: 20),
                          child: Center(
                            child: Text(
                              u.content,
                              style: TextStyle(
                                color: context.inputFieldText,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                height: 2,
                              ),
                              textAlign: TextAlign.center,
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
                            textAlign: TextAlign.center,
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
