import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  final PrayerModel prayer;

  @override
  NoUpdateView(this.prayer);
  Widget build(BuildContext context) {
    final username = userData.singleWhere((u) => u.id == prayer.user).name;
    final _userProvider = Provider.of<UserProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 30),
              child: Row(
                children: <Widget>[
                  Text(
                    '7:45am',
                    style: TextStyle(
                        color: context.dimBlue, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Text(
                      '|',
                      style: TextStyle(
                          color: context.dimBlue, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mma | MM.dd.yyyy').format(prayer.date),
                    style: TextStyle(
                        color: context.dimBlue, fontWeight: FontWeight.w500),
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
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
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
    );
  }
}
