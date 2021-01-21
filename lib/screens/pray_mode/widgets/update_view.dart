import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateView extends StatelessWidget {
  final CombinePrayerStream data;

  @override
  UpdateView(this.data);
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              data.prayer.userId != _currentUser.id
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        data.prayer.creatorName,
                        style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              ...data.updates.map(
                (u) => Container(
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
                                      .format(u.createdOn),
                                  style: TextStyle(
                                      color: AppColors.dimBlue,
                                      fontWeight: FontWeight.w500),
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
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 100.0, horizontal: 20),
                          child: Center(
                            child: Text(
                              u.description,
                              style: TextStyle(
                                color: AppColors.textFieldText,
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
                                style: TextStyle(
                                    color: AppColors.dimBlue,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat(' MM.dd.yyyy')
                                    .format(data.prayer.createdOn),
                                style: TextStyle(
                                    color: AppColors.dimBlue,
                                    fontWeight: FontWeight.w500),
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
                    Container(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                        child: Center(
                          child: Text(
                            data.prayer.description,
                            style: TextStyle(
                              color: AppColors.textFieldText,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
