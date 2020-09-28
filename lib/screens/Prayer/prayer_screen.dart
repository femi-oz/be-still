import 'package:async/async.dart';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/Widgets/find_a_group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar.dart';
import '../../utils/app_theme.dart';
import 'Widgets/prayer_menu.dart';
import 'Widgets/prayer_list.dart';

class PrayerScreen extends StatefulWidget {
  static const routeName = 'prayer-screen';
  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  var activeList;
  var groupId;
  List<PrayerModel> filteredprayers = [];

  final TextEditingController _searchController = TextEditingController();
  void _onTextchanged(String value) {
    setState(() {
      filteredprayers = screenPrayers
          .where(
              (p) => p.description.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _clearSearchField() {
    _searchController.text = '';
    filteredprayers = screenPrayers;
  }

  _setCurrentList(_activeList, _groupId) {
    setState(() {
      _clearSearchField();
      activeList = _activeList;
      groupId = _groupId;
    });
  }

  bool isInitialized = false;

  @override
  void initState() {
    activeList = PrayerActiveScreen.personal;
    super.initState();
  }

  List<PrayerModel> prayerList = [];
  List<PrayerModel> archivedPrayerList = [];
  List<PrayerModel> answeredPrayerList = [];
  List<PrayerModel> screenPrayers = [];

  // Future<Stream> getData() async {
  //   UserModel _user =
  //       Provider.of<UserProvider>(context, listen: false).currentUser;
  //   Stream prayersStream =
  //       await Provider.of<PrayerProvider>(context, listen: false)
  //           .getPrayers(_user);
  //   Stream archivedPrayersStream =
  //       await Provider.of<PrayerProvider>(context, listen: false)
  //           .getArchivedPrayers(_user);
  //   Stream answeredPrayersStream =
  //       await Provider.of<PrayerProvider>(context, listen: false)
  //           .getAnsweredPrayers(_user);
  //   return StreamZip(
  //           [prayersStream, archivedPrayersStream, answeredPrayersStream])
  //       .asBroadcastStream();
  // }

  // Future setupData() async {
  //   return await getData()
  //     ..asBroadcastStream().listen(
  //       (data) {
  //         List<PrayerModel> prayersRes = [];
  //         List<PrayerModel> archivedPrayersRes = [];
  //         List<PrayerModel> answeredPrayersRes = [];
  //         data[0].documents.map((doc) {
  //           prayersRes.add(PrayerModel.fromData(doc));
  //         }).toList();
  //         data[1].documents.map((doc) {
  //           archivedPrayersRes.add(PrayerModel.fromData(doc));
  //         }).toList();
  //         data[2].documents.map((doc) {
  //           answeredPrayersRes.add(PrayerModel.fromData(doc));
  //         }).toList();
  //         prayerList = prayersRes;
  //         archivedPrayerList = archivedPrayersRes;
  //         answeredPrayerList = answeredPrayersRes;

  //         return screenPrayers;
  //       },
  //     );
  // }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    return Scaffold(
      key: _scaffoldKey,
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
            image: AssetImage(_themeProvider.isDarkModeEnabled
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
                    clearSearchField: _clearSearchField,
                    searchController: _searchController,
                    setCurrentList: _setCurrentList,
                    activeList: activeList,
                    groupId: groupId,
                    onTextchanged: _onTextchanged),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.855,
                child: StreamBuilder(
                  stream:
                      Provider.of<PrayerProvider>(context).getPrayers(_user.id),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<CombinePrayerStream>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.brightBlue,
                              ),
                              backgroundColor: context.prayerMenuEnd,
                            ),
                          ],
                        );
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          final activePrayers = snapshot.data
                              .where((e) =>
                                  e.prayer.status == 'Active' &&
                                  e.prayer.isAnswer == false &&
                                  e.prayer.description.toLowerCase().contains(
                                      _searchController.text.toLowerCase()))
                              .toList();
                          final archivedPrayers = snapshot.data
                              .where((e) =>
                                  e.prayer.status == 'Inactive' &&
                                  e.prayer.description.toLowerCase().contains(
                                      _searchController.text.toLowerCase()))
                              .toList();
                          final answeredPrayers = snapshot.data
                              .where((e) =>
                                  e.prayer.isAnswer == false &&
                                  e.prayer.description.toLowerCase().contains(
                                      _searchController.text.toLowerCase()))
                              .toList();
                          return SingleChildScrollView(
                            child: activeList == PrayerActiveScreen.findGroup
                                ? FindAGroup()
                                : PrayerList(
                                    activeList: activeList,
                                    groupId: groupId,
                                    prayers: activeList ==
                                            PrayerActiveScreen.archived
                                        ? archivedPrayers
                                        : activeList ==
                                                PrayerActiveScreen.answered
                                            ? answeredPrayers
                                            : activeList ==
                                                    PrayerActiveScreen.personal
                                                ? activePrayers
                                                : [],
                                  ),
                          );
                        }
                    }
                  },
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
