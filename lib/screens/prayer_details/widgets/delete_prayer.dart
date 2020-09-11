import 'package:be_still/Models/prayer.model.dart';
import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class DeletePrayer extends StatelessWidget {
  final PrayerModel prayer;

  @override
  DeletePrayer(this.prayer);
  Widget build(BuildContext context) {
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
                color: context.brightBlue2,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(PrayerScreen.routeName);
            },
            child: Container(
              height: 30,
              width: double.infinity,
              margin: EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.prayerCardTags,
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
                      color: context.prayerCardTags,
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
                    Navigator.of(context)
                        .pushReplacementNamed(PrayerScreen.routeName);
                  },
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.inputFieldBorder,
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
                            color: context.brightBlue2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * .38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.inputFieldBorder,
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
                            color: context.brightBlue2,
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
