import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/Widgets/find_a_group.dart';
import 'package:be_still/screens/prayer/widgets/prayer_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar.dart';
import '../../utils/app_theme.dart';
import 'Widgets/prayer_menu.dart';

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

  void _clearSearchField() {
    _searchController.text = '';
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
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.855,
                child: StreamBuilder(
                  stream: Provider.of<PrayerProvider>(context)
                      .getUserPrayers(_user.id, activeList, groupId),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<PrayerModel>> snapshot) {
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
                          return SingleChildScrollView(
                            child: activeList == PrayerActiveScreen.findGroup
                                ? FindAGroup()
                                : PrayerList(
                                    activeList: activeList,
                                    groupId: groupId,
                                    prayers: snapshot.data,
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
