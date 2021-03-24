import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  // final PrayerModel prayer;
  // final List<PrayerUpdateModel> updates;

  static const routeName = '/update';

  @override
  UpdateView();
  Widget build(BuildContext context) {
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    final updates = prayerData.updates;
    updates.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              prayerData.prayer.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text(
                        prayerData.prayer.creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.prayerPrimaryColor,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                _buildDetail(
                    DateFormat('hh:mma |')
                        .format(updates[i].modifiedOn)
                        .toLowerCase(),
                    updates[i].modifiedOn,
                    updates[i].description),
              _buildDetail('Initial Prayer Request |',
                  prayerData.prayer.modifiedOn, prayerData.prayer.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(time, modifiedOn, description) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      time,
                      style: AppTextStyles.regularText15.copyWith(
                        color: AppColors.lightBlue4,
                      ),
                    ),
                    Text(
                      DateFormat(' MM.dd.yyyy').format(modifiedOn),
                      style: AppTextStyles.regularText15.copyWith(
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
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      description,
                      style: AppTextStyles.regularText18b.copyWith(
                        color: AppColors.prayerTextColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
