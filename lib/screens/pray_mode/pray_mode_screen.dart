import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/screens/pray_mode/Widgets/pray_mode_app_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

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

  void _getPrayers() async {
    try {} on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
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
