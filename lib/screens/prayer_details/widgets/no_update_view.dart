import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  @override
  NoUpdateView();
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
                    style: AppTextStyles.regularText18b.copyWith(
                        color: AppColors.prayerPrimaryColor,
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
                      DateFormat('hh:mma | MM.dd.yyyy')
                          .format(prayer.createdOn),
                      style: AppTextStyles.regularText15.copyWith(
                        color: AppColors.prayerPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.prayerPrimaryColor,
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
                  style: AppTextStyles.regularText22.copyWith(
                    color: AppColors.offWhite2,
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
