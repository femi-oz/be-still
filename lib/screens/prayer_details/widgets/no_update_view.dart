import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  @override
  NoUpdateView();
  Widget build(BuildContext context) {
    final prayer = Provider.of<PrayerProvider>(context).currentPrayer;
    // TODO
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          prayer.groupId != '0'
              ? Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    prayer.creatorName,
                    style: AppTextStyles.boldText16.copyWith(
                      color: AppColors.lightBlue4,
                    ),
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
                      DateFormat('hh:mma | MM.dd.yyyy')
                          .format(prayer.createdOn),
                      style: AppTextStyles.regularText13.copyWith(
                        color: AppColors.lightBlue4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.lightBlue4,
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
                  prayer.description,
                  style: AppTextStyles.regularText18b.copyWith(
                    color: AppColors.prayerTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
