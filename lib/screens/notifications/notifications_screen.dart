import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen();

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // final groupedNotfications = notificationData
  //     .fold(Map<String, List<dynamic>>(), (Map<String, List<dynamic>> a, b) {
  //       a.putIfAbsent(b.type, () => []).add(b);
  //       return a;
  //     })
  //     .values
  //     .where((n) => n.isNotEmpty)
  //     .map((n) => {
  //           'title': n.first.type,
  //           'id': int.parse(n.first.id),
  //           'notifications': n.toList()
  //         })
  //     .toList();
  @override
  void initState() {
    // TODO: implement initState
    // print(groupedNotfications);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: NotificationBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
            image: DecorationImage(
              image: AssetImage(_themeProvider.isDarkModeEnabled
                  ? 'assets/images/background-pattern-dark.png'
                  : 'assets/images/background-pattern.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: _buildPanel(),
          ),
        ),
        endDrawer: CustomDrawer(),
      ),
    );
  }

  Widget _buildPanel() {
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        child: Column(
          children: <Widget>[
            // ...groupedNotfications
            //     .map(
            //       (notificationByType) => Container(
            //         margin: EdgeInsets.only(bottom: 10.0),
            //         child: custom.ExpansionTile(
            //           iconColor: AppColors.lightBlue4,
            //           headerBackgroundColorStart: context.prayerMenuStart,
            //           headerBackgroundColorEnd: context.prayerMenuEnd,
            //           shadowColor: context.dropShadow,
            //           title: Container(
            //             margin: EdgeInsets.only(
            //                 left: MediaQuery.of(context).size.width * 0.1),
            //             child: Text(
            //               notificationByType['title'],
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   color: AppColors.getTextFieldText(_themeProvider.isDarkModeEnabled),
            //                   fontSize: 22,
            //                   fontWeight: FontWeight.w500),
            //             ),
            //           ),
            //           initiallyExpanded: false,
            //           children: <Widget>[
            //             for (int i = 0;
            //                 i < notificationByType['notifications'].length;
            //                 i++)
            //               Column(
            //                 children: [
            //                   SizedBox(height: 10),
            //                   GestureDetector(
            //                     onLongPressEnd: null,
            //                     onTap: null,
            //                     child: Container(
            //                       margin: EdgeInsets.only(left: 20.0),
            //                       decoration: BoxDecoration(
            //                         color: context.prayerCardBorder,
            //                         borderRadius: BorderRadius.only(
            //                           bottomLeft: Radius.circular(10),
            //                           topLeft: Radius.circular(10),
            //                         ),
            //                       ),
            //                       child: Container(
            //                         margin: EdgeInsetsDirectional.only(
            //                             start: 1, bottom: 1, top: 1),
            //                         padding: EdgeInsets.symmetric(
            //                             vertical: 10, horizontal: 20),
            //                         width: double.infinity,
            //                         decoration: BoxDecoration(
            //                           color: context.prayerCardBg,
            //                           borderRadius: BorderRadius.only(
            //                             bottomLeft: Radius.circular(9),
            //                             topLeft: Radius.circular(9),
            //                           ),
            //                         ),
            //                         child: Column(
            //                           children: <Widget>[
            //                             Row(
            //                               children: <Widget>[
            //                                 Expanded(
            //                                   child: Column(
            //                                     children: <Widget>[
            //                                       Row(
            //                                         mainAxisAlignment:
            //                                             MainAxisAlignment
            //                                                 .spaceBetween,
            //                                         children: <Widget>[
            //                                           notificationByType['notifications']
            //                                                           [i]
            //                                                       .creator !=
            //                                                   ''
            //                                               ? Text(
            //                                                   userData
            //                                                       .singleWhere((u) =>
            //                                                           u.id ==
            //                                                           notificationByType['notifications']
            //                                                                   [
            //                                                                   i]
            //                                                               .creator)
            //                                                       .fullName
            //                                                       .toUpperCase(),
            //                                                   style: TextStyle(
            //                                                     color: context
            //                                                         .brightBlue,
            //                                                     fontWeight:
            //                                                         FontWeight
            //                                                             .w500,
            //                                                     fontSize: 10,
            //                                                   ),
            //                                                 )
            //                                               : Container(),
            //                                           Row(
            //                                             children: <Widget>[
            //                                               Text(
            //                                                 groupData
            //                                                     .singleWhere((u) =>
            //                                                         u.id ==
            //                                                         notificationByType[
            //                                                                 'notifications'][i]
            //                                                             .group)
            //                                                     .name
            //                                                     .toUpperCase(),
            //                                                 style: TextStyle(
            //                                                   color: context
            //                                                       .prayerCardTags,
            //                                                   fontSize: 10,
            //                                                 ),
            //                                               ),
            //                                               Container(
            //                                                 margin: EdgeInsets
            //                                                     .symmetric(
            //                                                   horizontal: 10,
            //                                                 ),
            //                                                 child: Text(
            //                                                   '|',
            //                                                   style: TextStyle(
            //                                                       color: context
            //                                                           .prayerCardBorder),
            //                                                 ),
            //                                               ),
            //                                               Text(
            //                                                 DateFormat(
            //                                                         'MM.dd.yyyy')
            //                                                     .format(notificationByType[
            //                                                             'notifications'][i]
            //                                                         .date),
            //                                                 style: TextStyle(
            //                                                   color: context
            //                                                       .prayerCardPrayer,
            //                                                   fontSize: 10,
            //                                                 ),
            //                                               ),
            //                                             ],
            //                                           )
            //                                         ],
            //                                       ),
            //                                     ],
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                             Divider(
            //                               color: context.prayerDivider,
            //                               thickness: 0.5,
            //                             ),
            //                             Row(
            //                               children: <Widget>[
            //                                 Container(
            //                                   width: MediaQuery.of(context)
            //                                           .size
            //                                           .width *
            //                                       0.8,
            //                                   child: Text(
            //                                     notificationByType[
            //                                             'notifications'][i]
            //                                         .content
            //                                         .substring(0, 100),
            //                                     style: TextStyle(
            //                                       color:
            //                                           context.prayerCardPrayer,
            //                                       fontSize: 12,
            //                                       fontWeight: FontWeight.w300,
            //                                     ),
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ),

            //                   //   NotificationCard(
            //                   //       notificationByType['notifications'][i]),
            //                   // ),
            //                   SizedBox(height: 10),
            //                 ],
            //               )
            //           ],
            //         ),
            //       ),
            //     )
            //     .toList(),
          ],
        ),
      ),
    );
  }
}
