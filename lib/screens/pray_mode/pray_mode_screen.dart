import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/pray_mode/Widgets/pray_mode_app_bar.dart';
import 'package:be_still/screens/pray_mode/widgets/prayer_page.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(
              _user?.id,
              Provider.of<SettingsProvider>(context, listen: false)
                  .settings
                  .defaultSortBy);
    } on HttpException catch (e) {
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
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayerTimeList;
    return Scaffold(
      appBar: PrayModeAppBar(
        current: currentPage,
        totalPrayers: prayers.length,
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          return PrayerView(prayers[index]);
        },
        itemCount: prayers.length,
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
