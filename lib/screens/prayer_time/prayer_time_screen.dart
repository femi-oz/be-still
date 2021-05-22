import 'package:be_still/providers/misc_provider.dart';
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
  final _controller = PageController(initialPage: 0, keepPage: true);

  var currentPage = 0;

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
                child: PageView.builder(
                  controller: _controller,
                  // : prayers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return KeepAlive(
                      keepAlive: true,
                      child: PrayerView(prayers[index]),
                      key: ValueKey<String>(prayers[index].id),
                    );
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
                      onTap: () => widget.setCurrentIndex(0),
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
    );
  }
}
