import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final CombinePrayerStream data;

  @override
  UpdateView(this.data);
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final updates = data.updates;
    updates.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              data.prayer.userId != _currentUser.id
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        data.prayer.creatorName,
                        style: AppTextStyles.boldText20.copyWith(
                            color: Settings.isDarkMode
                                ? Color(0xFF009FD0)
                                : Color(0xFF003B87)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              for (int i = 0; i < updates.length; i++)
                Container(
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
                                      .format(updates[i].createdOn)
                                      .toLowerCase(),
                                  style: AppTextStyles.regularText18b.copyWith(
                                      color: AppColors.prayeModeBorder),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.prayeModeBorder,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 20),
                        child: i == 0
                            ? Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      updates[i].description,
                                      style: AppTextStyles.regularText16b
                                          .copyWith(
                                              color: AppColors.prayerTextColor),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      updates[i].description,
                                      style: AppTextStyles.regularText18b
                                          .copyWith(
                                              color: AppColors.prayerTextColor),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
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
                                'Initial Prayer | ',
                                style: AppTextStyles.boldText16
                                    .copyWith(color: AppColors.prayeModeBorder),
                              ),
                              Text(
                                DateFormat('MM.dd.yyyy')
                                    .format(data.prayer.createdOn),
                                style: AppTextStyles.boldText16
                                    .copyWith(color: AppColors.prayeModeBorder),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.prayeModeBorder,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              data.prayer.description,
                              style: AppTextStyles.regularText18b
                                  .copyWith(color: AppColors.prayerTextColor),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
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
