import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../add_prayer/add_prayer_screen.dart';
import 'prayer_card.dart';

class PrayerList extends StatefulWidget {
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  void _getPrayers() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(_user.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(_user.id);

      await Provider.of<PrayerProvider>(context, listen: false)
          .setHiddenPrayers(_user.id);
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayers(_user?.id);
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  bool _isInit = true;

  BuildContext selectedContext;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPrayers();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final data = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
        image: DecorationImage(
          image: AssetImage(
              StringUtils.getBackgroundImage(_themeProvider.isDarkModeEnabled)),
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            data.length == 0
                ? Container(
                    padding: EdgeInsets.only(
                        left: 60, right: 100, top: 60, bottom: 60),
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        'No Prayers in My List',
                        style: AppTextStyles.demiBoldText34,
                        textAlign: TextAlign.center,
                      ),
                    ))
                : Container(
                    child: Column(
                      children: <Widget>[
                        ...data
                            .map((e) => GestureDetector(
                                onTap: () async {
                                  await Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .setPrayer(e.prayer.id);
                                  await Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .setPrayerUpdates(e.prayer.id);
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new PrayerDetails(),
                                    ),
                                  );
                                },
                                child: PrayerCard(prayer: e.prayer)))
                            .toList(),
                      ],
                    ),
                  ),
            currentPrayerType == PrayerType.archived ||
                    currentPrayerType == PrayerType.answered
                ? Container()
                : LongButton(
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPrayer(isEdit: false, isGroup: false),
                      ),
                    ),
                    text: 'Add New Prayer',
                    backgroundColor: _themeProvider.isDarkModeEnabled
                        ? AppColors.backgroundColor[1]
                        : AppColors.lightBlue3,
                    textColor: _themeProvider.isDarkModeEnabled
                        ? AppColors.lightBlue3
                        : Colors.white,
                    icon: Icons.add,
                  ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
