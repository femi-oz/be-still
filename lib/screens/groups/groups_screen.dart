import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
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
  Future<bool> _onWillPop() async {
    return (NavigationService.instance.goHome(0)) ?? false;
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('MY GROUPS');
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<GroupProvider>(context).userGroups;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        // padding: EdgeInsets.only(left: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.backgroundImage(Settings.isDarkMode)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 50),
                child: LongButton(
                  onPress: () => null,
                  // Navigator.push(
                  //   context,
                  //   new MaterialPageRoute(
                  //     builder: (context) =>
                  //     new FindAGroup(),
                  //   ),
                  // ),
                  text: 'FIND A GROUP',
                  backgroundColor:
                      AppColors.groupActionBgColor.withOpacity(0.9),
                  textColor: AppColors.addprayerTextColor,
                  hasIcon: false,
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.only(left: 50),
                child: LongButton(
                  onPress: () => null,
                  text: 'CREATE A GROUP',
                  backgroundColor:
                      AppColors.groupActionBgColor.withOpacity(0.9),
                  textColor: AppColors.addprayerTextColor,
                  hasIcon: false,
                ),
              ),
              SizedBox(height: 30),
              data.length == 0
                  ? Container(
                      padding: EdgeInsets.only(right: 20, left: 20),
                      child: Text(
                        'You are currently not in any groups',
                        style: AppTextStyles.demiboldText34,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Column(
                        children: <Widget>[
                          ...data
                              .map(
                                (e) => Column(
                                  children: [
                                    LongButton(
                                      onPress: () {},
                                      text: e.group.name.toUpperCase(),
                                      backgroundColor:
                                          AppColors.groupCardBgColor,
                                      textColor: AppColors.lightBlue3,
                                      hasIcon: false,
                                      hasMore: true,
                                      onPressMore: () => null,
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
      ),
    );
  }
}
