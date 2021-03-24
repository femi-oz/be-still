import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/pray_mode/Widgets/pray_mode_app_bar.dart';
import 'package:be_still/screens/pray_mode/widgets/prayer_page.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
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
          .setPrayerTimePrayers(_user.id);
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
      backgroundColor: AppColors.prayeModeBg,
      appBar: PrayModeAppBar(
        current: currentPage,
        totalPrayers: prayers.length,
      ),
      body: Column(
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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: Icon(Icons.first_page,color: AppColors.lightBlue3),
                onTap: () {
                  _controller.animateToPage(0,
                      curve: Curves.easeIn,
                      duration: Duration(milliseconds: 200));
                },
              ),
              SizedBox(width: 10),
              InkWell(
                child: Icon(Icons.navigate_before,color: AppColors.lightBlue3),
                onTap: () {
                  if (currentPage > 1) {
                    _controller.jumpToPage(currentPage - 2);
                  }
                },
              ),
              SizedBox(width: 10),
              InkWell(
                  child: Icon(Icons.navigate_next,color: AppColors.lightBlue3),
                  onTap: () {
                    if (currentPage < prayers.length) {
                      _controller.jumpToPage(currentPage);
                    }
                  }),
              SizedBox(width: 10),
              InkWell(
                child: Icon(Icons.last_page, color: AppColors.lightBlue3),
                onTap: () {
                  _controller.animateToPage(prayers.length - 1,
                      curve: Curves.easeIn,
                      duration: Duration(milliseconds: 200));
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
