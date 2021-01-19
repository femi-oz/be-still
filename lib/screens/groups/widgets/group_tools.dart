import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupTools extends StatefulWidget {
  @override
  _GroupToolsState createState() => _GroupToolsState();
}

class _GroupToolsState extends State<GroupTools> {
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

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(left: 40),
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
        ),
        image: DecorationImage(
          image: AssetImage(
              StringUtils.getBackgroundImage(_themeProvider.isDarkModeEnabled)),
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              FlatButton.icon(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.lightBlue4,
                ),
                onPressed: () => Navigator.pop(context),
                label: Text(
                  'BACK',
                  style: AppTextStyles.boldText20.copyWith(
                    color: AppColors.getPrayerPrimaryColor(
                        _themeProvider.isDarkModeEnabled),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          LongButton(
            icon: Icons.settings,
            onPress: () {
              _getPrayers(Provider.of<GroupProvider>(context, listen: false)
                  .currentGroup);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupPrayers(),
                ),
              );
            },
            text: "View Group",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.add,
            onPress: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPrayer(
                  isEdit: false,
                  isGroup: true,
                ),
              ),
            ),
            text: "Add a Prayer",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.more_vert,
            onPress: null,
            text: "Manage Settings",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.share,
            onPress: null,
            text: "Invite - Email",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.share,
            onPress: null,
            text: "Invite - Text",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.share,
            onPress: null,
            text: "Invite - QR Code",
            backgroundColor: _themeProvider.isDarkModeEnabled
                ? AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled)[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}