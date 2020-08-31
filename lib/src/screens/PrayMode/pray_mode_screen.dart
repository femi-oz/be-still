import 'package:be_still/src/Data/prayer.data.dart';
import 'package:be_still/src/screens/PrayMode/Widgets/pray_mode_app_bar.dart';
import 'package:be_still/src/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

import 'Widgets/prayer_page.dart';

class PrayerMode extends StatefulWidget {
  static const routeName = '/prayer-mode';

  @override
  _PrayerModeState createState() => _PrayerModeState();
}

class _PrayerModeState extends State<PrayerMode> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  var currentPage = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrayModeAppBar(
        current: currentPage,
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
         return PrayerPage(prayerData[index]);
        },
        itemCount: prayerData.length,
        onPageChanged: (value) => {
          setState(
            () => {
              currentPage = value + 1,
            },
          ),
        },
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
