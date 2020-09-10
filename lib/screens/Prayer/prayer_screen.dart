import 'package:be_still/Data/group.data.dart';
import 'package:be_still/Data/prayer.data.dart';
import 'package:be_still/Enums/prayer_list.enum.dart';
import 'package:be_still/Models/prayer.model.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/find_a_group.dart';
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
  var activeList = PrayerActiveScreen.personal;
  var groupId;

  final List<PrayerModel> emptyList = [];
  List<PrayerModel> prayers = [];
  List<PrayerModel> filteredprayers = [];

  void _onTextchanged(String value) {
    print(value);
    setState(() {
      filteredprayers = prayers
          .where((p) => p.content.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  _setCurrentList(_activeList, _groupId) {
    setState(() {
      activeList = _activeList;
      groupId = _groupId;
    });
  }

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    if (!isInitialized) {
      isInitialized = true;
      setState(
        () {
          prayers = activeList == PrayerActiveScreen.personal
              ? prayerData
                  .where((p) =>
                      _app.user.prayerList.contains(p.id) &&
                      p.status == 'active')
                  .toList()
              : activeList == PrayerActiveScreen.archived
                  ? prayerData
                      .where((p) =>
                          _app.user.prayerList.contains(p.id) &&
                          p.status == 'archived')
                      .toList()
                  : activeList == PrayerActiveScreen.answered
                      ? prayerData
                          .where((p) =>
                              _app.user.prayerList.contains(p.id) &&
                              p.status == 'answered')
                          .toList()
                      : activeList == PrayerActiveScreen.group
                          ? prayerData
                              .where((p) => groupData
                                  .singleWhere((g) => g.id == groupId)
                                  .prayerList
                                  .contains(p.id))
                              .toList()
                          : emptyList;
          filteredprayers = prayers;
        },
      );
    }
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
                    setCurrentList: _setCurrentList,
                    activeList: activeList,
                    groupId: groupId,
                    onTextchanged: _onTextchanged),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.825,
                child: SingleChildScrollView(
                  child: activeList == PrayerActiveScreen.findGroup
                      ? FindAGroup()
                      : PrayerList(
                          activeList: activeList,
                          groupId: groupId,
                          prayers: filteredprayers),
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
