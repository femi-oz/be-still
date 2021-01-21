import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/screens/groups/widgets/find_a_group.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
import 'package:be_still/screens/groups/widgets/group_tools.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = 'group-screen';
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  void _getPrayers(CombineGroupUserStream data) async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(_user.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(_user.id);

      await Provider.of<PrayerProvider>(context, listen: false)
          .setHiddenPrayers(_user.id);
      await Provider.of<PrayerProvider>(context, listen: false).setGroupPrayers(
        _user?.id,
        data.group.id,
        data.groupUsers.firstWhere((e) => e.userId == _user.id).isAdmin,
      );
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  _onPressMore(String id, _themeProvider, CombineGroupUserStream group) {
    Provider.of<GroupProvider>(context, listen: false).setCurrentGroup(group);
    showModalBottomSheet(
      context: context,
      barrierColor: AppColors.detailBackgroundColor[1].withOpacity(0.5),
      backgroundColor: AppColors.detailBackgroundColor[1].withOpacity(0.9),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GroupTools();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final data = Provider.of<GroupProvider>(context).userGroups;
    return Container(
      padding: EdgeInsets.only(left: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
        image: DecorationImage(
          image:
              AssetImage(StringUtils.getBackgroundImage(Settings.isDarkMode)),
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            LongButton(
              onPress: () => Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new FindAGroup(),
                ),
              ),
              text: 'FIND A GROUP',
              backgroundColor: Settings.isDarkMode
                  ? AppColors.backgroundColor[1]
                  : AppColors.lightBlue3,
              textColor:
                  Settings.isDarkMode ? AppColors.lightBlue3 : Colors.white,
              hasIcon: false,
            ),
            SizedBox(height: 5),
            LongButton(
              onPress: () => Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => CreateGroupScreen(),
                ),
              ),
              text: 'CREATE A GROUP',
              backgroundColor: Settings.isDarkMode
                  ? AppColors.backgroundColor[1]
                  : AppColors.lightBlue3,
              textColor:
                  Settings.isDarkMode ? AppColors.lightBlue3 : Colors.white,
              hasIcon: false,
            ),
            SizedBox(height: 30),
            data.length == 0
                ? Container(
                    padding: EdgeInsets.all(60),
                    child: Text(
                      'You are currently not in any groups',
                      style: AppTextStyles.regularText13,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(
                    child: Column(
                      children: <Widget>[
                        ...data
                            .map(
                              (e) => Column(
                                children: [
                                  LongButton(
                                    onPress: () {
                                      _getPrayers(e);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GroupPrayers(),
                                        ),
                                      );
                                    },
                                    text: e.group.name.toUpperCase(),
                                    backgroundColor: Settings.isDarkMode
                                        ? AppColors.backgroundColor[0]
                                        : Colors.white,
                                    textColor: AppColors.lightBlue3,
                                    hasIcon: false,
                                    hasMore: true,
                                    onPressMore: () => _onPressMore(
                                        e.group.id, _themeProvider, e),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
