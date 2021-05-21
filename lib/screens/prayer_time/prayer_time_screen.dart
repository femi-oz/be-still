import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_time/widgets/prayer_page.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:preload_page_view/preload_page_view.dart';

class PrayerTime extends StatefulWidget {
  final Function setCurrentIndex;
  PrayerTime(this.setCurrentIndex);
  static const routeName = '/prayer-time';

  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  final _controller = PreloadPageController(initialPage: 0);

  var currentPage = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    widget.setCurrentIndex(0, true);
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayerTimeList;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                child: PreloadPageView.builder(
                  controller: _controller,
                  itemBuilder: (context, index) {
                    return PrayerView(prayers[currentPage - 1]);
                  },
                  itemCount: prayers.length,
                  preloadPagesCount: prayers.length,
                  onPageChanged: (value) => {
                    setState(() => currentPage = value + 1),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Transform.rotate(
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
                    InkWell(
                      child: Icon(
                        Icons.navigate_before,
                        color: currentPage > 1
                            ? AppColors.lightBlue3
                            : AppColors.grey,
                        size: 30,
                      ),
                      onTap: () {
                        if (currentPage > 1) {
                          _controller.jumpToPage(currentPage - 2);
                        }
                      },
                    ),
                    InkWell(
                      child: Icon(
                        AppIcons.bestill_close,
                        color: AppColors.lightBlue3,
                        size: 30,
                      ),
                      onTap: () => widget.setCurrentIndex(0, true),
                    ),
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
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
