import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_time/widgets/prayer_page.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class PrayerTime extends StatefulWidget {
  final Function setCurrentPage;
  PrayerTime(this.setCurrentPage);
  static const routeName = '/prayer-time';

  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  var currentPage = 1;

  void _getPrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPrayers();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayerTimeList;
    return Scaffold(
      backgroundColor: AppColors.prayeModeBg,
      body: Container(
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
                itemBuilder: (context, index) {
                  return PrayerView(prayers[currentPage - 1]);
                },
                itemCount: prayers.length,
                onPageChanged: (value) => {
                  setState(() => currentPage = value + 1),
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.12,
                        right: MediaQuery.of(context).size.width * 0.005),
                    child: Transform.rotate(
                      angle: 180 * math.pi / 180,
                      child: InkWell(
                        child: Icon(
                          Icons.keyboard_tab,
                          color: currentPage > 1
                              ? AppColors.lightBlue3
                              : AppColors.grey,
                          size: 30,
                        ),
                        onTap: () {
                          if (currentPage > 1) {
                            _controller.animateToPage(0,
                                curve: Curves.easeIn,
                                duration: Duration(milliseconds: 200));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.095),
                InkWell(
                  child: Icon(
                    Icons.navigate_before,
                    color:
                        currentPage > 1 ? AppColors.lightBlue3 : AppColors.grey,
                    size: 30,
                  ),
                  onTap: () {
                    if (currentPage > 1) {
                      _controller.jumpToPage(currentPage - 2);
                    }
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.095),
                InkWell(
                  child: Icon(
                    AppIcons.bestill_close,
                    color: AppColors.lightBlue3,
                    size: 30,
                  ),
                  onTap: () => widget.setCurrentPage(0),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.095),
                InkWell(
                    child: Icon(
                      Icons.navigate_next,
                      color: currentPage < prayers.length
                          ? AppColors.lightBlue3
                          : AppColors.grey,
                      size: 30,
                    ),
                    onTap: () {
                      if (currentPage < prayers.length) {
                        _controller.jumpToPage(currentPage);
                      }
                    }),
                SizedBox(width: MediaQuery.of(context).size.width * 0.095),
                InkWell(
                  child: Icon(
                    Icons.keyboard_tab,
                    color: currentPage < prayers.length
                        ? AppColors.lightBlue3
                        : AppColors.grey,
                    size: 30,
                  ),
                  onTap: () {
                    if (currentPage < prayers.length) {
                      _controller.animateToPage(prayers.length - 1,
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 200));
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
