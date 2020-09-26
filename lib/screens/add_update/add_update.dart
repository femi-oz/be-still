import 'package:be_still/data/prayer.data.dart';
import 'package:be_still/data/user.data.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddUpdate extends StatelessWidget {
  // PrayerModel prayer;
  static const routeName = 'update-prayer';

  @override
  // AddUpdate(this.prayer);
  Widget build(BuildContext context) {
    final String prayerId = ModalRoute.of(context).settings.arguments;
    // TODO
    // final prayer = prayerData.singleWhere((p) => p.id == prayerId);

    // TODO
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    final username = currentUser.firstName;
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.mainBgStart,
                context.mainBgEnd,
              ],
            ),
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                            color: context.toolsBackBtn, fontSize: 16),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    InkWell(
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                            color: context.toolsBackBtn, fontSize: 16),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    color: context.inputFieldBg.withOpacity(0.5),
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      initialValue: '',
                      style: TextStyle(
                        color: context.inputFieldText,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 25,
                      decoration: InputDecoration.collapsed(
                          hintStyle: TextStyle(
                            color: context.inputFieldText,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                          hintText: "Enter your text here"),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.prayerDetailsCardBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // TODO
                      // prayer.user != _currentUser.id
                      //     ? Container(
                      //         margin: EdgeInsets.only(bottom: 20),
                      //         child: Text(
                      //           username,
                      //           style: TextStyle(
                      //               color: context.brightBlue,
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.w500),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //       )
                      //     : Container(),
                      // ...prayer.updates.map(
                      //   (u) => Container(
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: <Widget>[
                      //         Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: <Widget>[
                      //             Container(
                      //               margin: EdgeInsets.only(right: 30),
                      //               child: Row(
                      //                 children: <Widget>[
                      //                   Text(
                      //                     DateFormat('hh:mma | MM.dd.yyyy')
                      //                         .format(u.date),
                      //                     style: TextStyle(
                      //                         color: context.dimBlue,
                      //                         fontWeight: FontWeight.w500),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             Expanded(
                      //               child: Divider(
                      //                 color: context.prayerDetailsCardBorder,
                      //                 thickness: 1,
                      //               ),
                      //             ),
                      //             ...u.tags
                      //                 .map(
                      //                   (t) => Container(
                      //                     margin: EdgeInsets.only(left: 10),
                      //                     child: Row(
                      //                       children: <Widget>[
                      //                         Text(
                      //                           t.toUpperCase(),
                      //                           style: TextStyle(
                      //                             color: context.prayerCardTags,
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 )
                      //                 .toList()
                      //           ],
                      //         ),
                      //         Container(
                      //           child: Padding(
                      //             padding: EdgeInsets.all(20),
                      //             child: Center(
                      //               child: Text(
                      //                 u.content,
                      //                 style: TextStyle(
                      //                   color: context.inputFieldText,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w300,
                      //                   height: 2,
                      //                 ),
                      //                 textAlign: TextAlign.center,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   child: Column(
                      //     children: <Widget>[
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: <Widget>[
                      //           Container(
                      //             margin: EdgeInsets.only(right: 30),
                      //             child: Row(
                      //               children: <Widget>[
                      //                 Text(
                      //                   'Initial Prayer Request |',
                      //                   style: TextStyle(
                      //                       color: context.dimBlue,
                      //                       fontSize: 12,
                      //                       fontWeight: FontWeight.w500),
                      //                 ),
                      //                 Text(
                      //                   DateFormat(' MM.dd.yyyy')
                      //                       .format(prayer.date),
                      //                   style: TextStyle(
                      //                       fontSize: 12,
                      //                       color: context.dimBlue,
                      //                       fontWeight: FontWeight.w500),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Divider(
                      //               color: context.prayerDetailsCardBorder,
                      //               thickness: 1,
                      //             ),
                      //           ),
                      //           ...prayer.tags
                      //               .map(
                      //                 (t) => Container(
                      //                   margin: EdgeInsets.only(left: 10),
                      //                   child: Text(
                      //                     t.toUpperCase(),
                      //                     style: TextStyle(
                      //                       fontSize: 12,
                      //                       color: context.prayerCardTags,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               )
                      //               .toList(),
                      //         ],
                      //       ),
                      //       Container(
                      //         child: Padding(
                      //           padding: EdgeInsets.symmetric(
                      //               vertical: 8.0, horizontal: 20),
                      //           child: Center(
                      //             child: Text(
                      //               prayer.content,
                      //               style: TextStyle(
                      //                 color: context.inputFieldText,
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.w300,
                      //                 height: 2,
                      //               ),
                      //               textAlign: TextAlign.center,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
