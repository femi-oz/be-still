import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatelessWidget {
  final CombinePrayerStream data;

  @override
  NoUpdateView(this.data);
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              data.prayer.userId != _currentUser.id
                  ? Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        data.prayer.creatorName,
                        style: AppTextStyles.regularText18b.copyWith(
                            color: AppColors.lightBlue4,
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
                              .format(data.prayer.modifiedOn)
                              .toLowerCase(),
                          style: AppTextStyles.regularText18b
                              .copyWith(color: AppColors.prayeModeBorder),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data.prayer.description,
                        style: AppTextStyles.regularText18b
                            .copyWith(color: AppColors.prayerTextColor),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
