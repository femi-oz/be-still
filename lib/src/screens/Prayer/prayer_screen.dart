import 'package:be_still/src/Enums/prayer_list.enum.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/Theme/app_theme.dart';
import 'Widgets/prayer_menu.dart';
import 'Widgets/prayer_list.dart';

class PrayerScreen extends StatefulWidget {
  static const routeName = 'prayer-screen';
  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  var activeList = PrayerListType.personal;
  var groupId;
  var searchParam = TextEditingController();

  setCurrentList(_activeList, _groupId) {
    setState(() {
      activeList = _activeList;
      groupId = _groupId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.mainBgStart,
              context.mainBgEnd,
            ],
          ),
          image: DecorationImage(
            image: AssetImage(_app.isDarkModeEnabled
                ? 'assets/images/background-pattern-dark.png'
                : 'assets/images/background-pattern.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                child: PrayerMenu(
                    setCurrentList, activeList, groupId, searchParam),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.825,
                child: SingleChildScrollView(
                  child: PrayerList(activeList, groupId, searchParam),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
