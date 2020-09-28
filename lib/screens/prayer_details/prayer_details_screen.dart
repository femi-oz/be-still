import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/pray_mode/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerDetails extends StatelessWidget {
  static const routeName = '/prayer-details';
  @override
  Widget build(BuildContext context) {
    final PrayerDetailsRouteArguments args =
        ModalRoute.of(context).settings.arguments;
    PrayerModel prayer;
    return StreamBuilder(
        stream: Provider.of<PrayerProvider>(context).fetchPrayer(args.id),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            prayer = PrayerModel.fromData(snapshot.data);
            return Scaffold(
              appBar: CustomAppBar(),
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
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton.icon(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.arrow_back,
                              color: context.toolsBackBtn,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(PrayerScreen.routeName);
                            },
                            label: Text(
                              'BACK',
                              style: TextStyle(
                                color: context.toolsBackBtn,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // prayer.hasReminder
                          //     ? Row(
                          //         children: <Widget>[
                          //           Icon(
                          //             Icons.calendar_today,
                          //             size: 14,
                          //             color: context.toolsBackBtn,
                          //           ),
                          //           Container(
                          //             margin: EdgeInsets.only(left: 10),
                          //             child: Text(
                          //               prayer.reminder,
                          //               style: TextStyle(
                          //                 color: context.toolsBackBtn,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          //     : Container(),
                        ],
                      ),
                    ),
                    // TODO
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                context.prayerDetailsCardStart,
                                context.prayerDetailsCardEnd,
                              ],
                            ),
                            border: Border.all(
                              color: context.prayerDetailsCardBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: NoUpdateView(prayer)
                          // prayer.updates.length > 0
                          //     ? UpdateView(prayer)
                          //     : NoUpdateView(prayer),
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: context.brightBlue,
                      ),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        barrierColor: context.toolsBg.withOpacity(0.5),
                        backgroundColor: context.toolsBg.withOpacity(0.9),
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return PrayerMenu(prayer);
                          // isUserPrayer
                          //     ? PrayerMenu(prayer)
                          //     : prayer.isAddedFromGroup && isGroupAdmin
                          //         ? GroupAdminPrayerMenu(prayer)
                          //         : prayer.isAddedFromGroup && !isGroupAdmin
                          //             ? OtherMemberPrayerMenu(prayer)
                          //             : Container();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              endDrawer: CustomDrawer(),
            );
          } else {
            return Text('No Prayer Available');
          }
        });
  }
}

class PrayerDetailsRouteArguments {
  final String id;
  // final String groupId;

  PrayerDetailsRouteArguments(
    this.id,
    // this.groupId,
  );
}
