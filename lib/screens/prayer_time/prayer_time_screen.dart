import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/v2/misc_provider.dart';

import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/prayer_time/widgets/prayer_page.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      try {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchMode(false);
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchQuery('');
        Provider.of<PrayerProviderV2>(context, listen: false)
            .searchPrayers('', userId ?? '');
      } catch (e, s) {
        final user =
            Provider.of<UserProviderV2>(context, listen: false).selectedUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    AppController appController = Get.find();
    appController.setCurrentPage(0, true, 2);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var prayers = Provider.of<PrayerProviderV2>(context).filteredPrayerTimeList;
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
                          AppController appController = Get.find();
                          appController.setCurrentPage(0, true, 2);
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
