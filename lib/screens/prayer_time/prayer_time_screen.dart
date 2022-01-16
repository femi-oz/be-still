import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_time/widgets/prayer_page.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class PrayerTime extends StatefulWidget {
  static const routeName = '/prayer-time';

  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  final _controller = PageController(initialPage: 0);
  var currentPage = 0;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      var userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchMode(false);
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchQuery('');
      Provider.of<PrayerProvider>(context, listen: false)
          .searchPrayers('', userId);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    AppCOntroller appCOntroller = Get.find();

    appCOntroller.setCurrentPage(0, true);
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayerTimeList;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.prayeModeBg,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundColor,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      return PrayerView(prayers[index]);
                    },
                    itemCount: prayers.length,
                    onPageChanged: (index) {
                      setState(() => currentPage = index);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.rotate(
                        angle: 180 * math.pi / 180,
                        child: InkWell(
                          child: Icon(
                            Icons.keyboard_tab,
                            color: currentPage > 0
                                ? AppColors.lightBlue3
                                : AppColors.grey,
                            size: 30,
                          ),
                          onTap: () {
                            if (currentPage > 0) {
                              _controller.animateToPage(0,
                                  curve: Curves.easeIn,
                                  duration: Duration(milliseconds: 200));
                              setState(() => currentPage = 0);
                            }
                          },
                        ),
                      ),
                      InkWell(
                        child: Icon(
                          Icons.navigate_before,
                          color: currentPage > 0
                              ? AppColors.lightBlue3
                              : AppColors.grey,
                          size: 30,
                        ),
                        onTap: () {
                          if (currentPage > 0) {
                            _controller.animateToPage(currentPage - 1,
                                curve: Curves.easeIn,
                                duration: Duration(milliseconds: 200));
                            setState(() => currentPage -= 1);
                          }
                        },
                      ),
                      InkWell(
                        child: Icon(
                          AppIcons.bestill_close,
                          color: AppColors.lightBlue3,
                          size: 30,
                        ),
                        onTap: () {
                          AppCOntroller appCOntroller = Get.find();

                          appCOntroller.setCurrentPage(0, true);
                        },
                      ),
                      InkWell(
                          child: Icon(
                            Icons.navigate_next,
                            color: currentPage < prayers.length - 1
                                ? AppColors.lightBlue3
                                : AppColors.grey,
                            size: 30,
                          ),
                          onTap: () {
                            if (currentPage < prayers.length - 1) {
                              _controller.animateToPage(currentPage + 1,
                                  curve: Curves.easeIn,
                                  duration: Duration(milliseconds: 200));
                              setState(() => currentPage += 1);
                            }
                          }),
                      InkWell(
                        child: Icon(
                          Icons.keyboard_tab,
                          color: currentPage < prayers.length - 1
                              ? AppColors.lightBlue3
                              : AppColors.grey,
                          size: 30,
                        ),
                        onTap: () {
                          if (currentPage < prayers.length - 1) {
                            _controller.animateToPage(prayers.length - 1,
                                curve: Curves.easeIn,
                                duration: Duration(milliseconds: 200));
                            setState(() => currentPage = prayers.length - 1);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
