import 'package:be_still/data/prayer.data.dart';
import 'package:be_still/screens/pray_mode/Widgets/pray_mode_app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
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
          // TODO
          // return PrayerPage(prayerData[index]);
        },
        // TODO
        // itemCount: prayerData.length,
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
