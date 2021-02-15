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
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              prayerData.prayer.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        prayerData.prayer.creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.prayerPrimaryColor,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              ...prayerData.updates.map(
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
                                      .format(u.modifiedOn),
                                  style: AppTextStyles.regularText14.copyWith(
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
                          //                 color: AppColors.red,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     )
                          //     .toList()
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  u.description,
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
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.lightBlue4,
                                ),
                              ),
                              Text(
                                DateFormat(' MM.dd.yyyy')
                                    .format(prayerData.prayer.modifiedOn),
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
                        // TODO
                        // ...prayer.tags
                        //     .map(
                        //       (t) => Container(
                        //         margin: EdgeInsets.only(left: 10),
                        //         child: Text(
                        //           t.toUpperCase(),
                        //           style: TextStyle(
                        //             color: AppColors.red,
                        //           ),
                        //         ),
                        //       ),
                        //     )
                        //     .toList(),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                prayerData.prayer.description,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
