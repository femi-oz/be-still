import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_time/widgets/prayer_page.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class PrayerTime extends StatefulWidget {
  final Function setCurrentIndex;
  final ValueNotifier<double> notifier;

  PrayerTime(this.setCurrentIndex, this.notifier);
  static const routeName = '/prayer-time';

  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  int _previousPage;

  var currentPage = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Consider the page changed when the end of the scroll is reached
    // Using onPageChanged callback from PageView causes the page to change when
    // the half of the next card hits the center of the viewport, which is not
    // what I want

    if (_controller.page.toInt() == _controller.page) {
      _previousPage = _controller.page.toInt();
    }
    widget.notifier?.value = _controller.page - _previousPage;
  }

  @override
  void initState() {
    _controller = PageController(
      initialPage: 0,
      viewportFraction: 0.9,
    )..addListener(_onScroll);

    _previousPage = _controller.initialPage;
    super.initState();
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
    List<Widget> _pages = List.generate(prayers.length, (index) {
      return PrayerView(prayers[currentPage - 1]);
    });
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
                child: PageView(
                  controller: _controller,
                  children: _pages,

                  // itemCount: prayers.length,
                  onPageChanged: (value) => {
                    setState(() => currentPage = value + 1),
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.095),
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
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.095),
                    InkWell(
                      child: Icon(
                        AppIcons.bestill_close,
                        color: AppColors.lightBlue3,
                        size: 30,
                      ),
                      onTap: () => widget.setCurrentIndex(0, true),
                    ),
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.095),
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
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.095),
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
