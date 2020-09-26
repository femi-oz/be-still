import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  final PrayerModel prayer;

  @override
  NoUpdateView(this.prayer);
  Widget build(BuildContext context) {
    // TODO
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    final username = currentUser.firstName;
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Column(
      children: <Widget>[
        prayer.userId != _currentUser.id
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
                    DateFormat('hh:mma | MM.dd.yyyy').format(prayer.createdOn),
                    style: TextStyle(
                        color: context.dimBlue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: context.prayModeCardBorder,
                thickness: 1,
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                prayer.description,
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
    );
  }
}
