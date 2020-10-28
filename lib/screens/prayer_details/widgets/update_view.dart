import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final PrayerModel prayer;
  final List<PrayerUpdateModel> updates;

  static const routeName = '/update';

  @override
  UpdateView(this.prayer, this.updates);
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              prayer.groupId != '0'
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        prayer.createdBy,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Container(),
              ...updates.map(
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
                                      .format(prayer.createdOn),
                                  style: AppTextStyles.regularText16.copyWith(
                                    color: AppColors.getAppBarColor(
                                        _themeProvider.isDarkModeEnabled),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.getAppBarColor(
                                _themeProvider.isDarkModeEnabled,
                              ),
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
                          //                 color: context.prayerCardTags,
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
                              Text(
                                u.description,
                                style: AppTextStyles.regularText22.copyWith(
                                  color: AppColors.getTextFieldBgColor(
                                    !_themeProvider.isDarkModeEnabled,
                                  ),
                                ),
                                textAlign: TextAlign.left,
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
                                style: AppTextStyles.regularText16.copyWith(
                                  color: AppColors.getAppBarColor(
                                      _themeProvider.isDarkModeEnabled),
                                ),
                              ),
                              Text(
                                DateFormat(' MM.dd.yyyy')
                                    .format(prayer.createdOn),
                                style: AppTextStyles.regularText16.copyWith(
                                  color: AppColors.getAppBarColor(
                                      _themeProvider.isDarkModeEnabled),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.darkBlue2,
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
                        //             color: context.prayerCardTags,
                        //           ),
                        //         ),
                        //       ),
                        //     )
                        //     .toList(),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 200,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
