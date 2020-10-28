import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  final PrayerModel prayer;

  @override
  NoUpdateView(this.prayer);
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    // TODO
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // TODO
        prayer.groupId != '0'
            ? Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  prayer.createdBy,
                  style: AppTextStyles.regularText18b.copyWith(
                      color: AppColors.getPrayerPrimaryColor(
                          _themeProvider.isDarkModeEnabled),
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
                    style: AppTextStyles.regularText16.copyWith(
                      color: AppColors.getPrayerPrimaryColor(
                          _themeProvider.isDarkModeEnabled),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.getPrayerPrimaryColor(
                  _themeProvider.isDarkModeEnabled,
                ),
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
                  color: AppColors.getTextFieldBgColor(
                    !_themeProvider.isDarkModeEnabled,
                  ),
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
