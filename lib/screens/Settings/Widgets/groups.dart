import 'package:be_still/data/group.data.dart';
import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/theme_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/widgets//custom_expansion_tile.dart' as custom;
import 'package:provider/provider.dart';

import 'group_privilege.dart';

class GroupsSettings extends StatefulWidget {
  @override
  _GroupsSettingsState createState() => _GroupsSettingsState();
}

class _GroupsSettingsState extends State<GroupsSettings> {
  void _getGroups() async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    await Provider.of<GroupProvider>(context, listen: false)
        .setUserGroups(_user.id);
    super.initState();
  }

  void _showAlert(GroupUserModel user) {
    final _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor:
          AppColors.getPrayerCardBgColor(_themeProvider.isDarkModeEnabled),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        // height: MediaQuery.of(context).size.height * 0.6,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.userId.toUpperCase(), //TODO
                        style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      Text(
                        user.userId,
                        style: TextStyle(
                            color: AppColors.getTextFieldText(
                                _themeProvider.isDarkModeEnabled),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.5),
                      ),
                      Text(
                        'might be from Houston, TX',
                        style: TextStyle(
                            color: AppColors.getTextFieldText(
                                _themeProvider.isDarkModeEnabled),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Has been a member since 01.07.08',
                          style: TextStyle(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 40.0),
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          // color: sortBy == 'date'
                          //     ? context.toolsActiveBtn.withOpacity(0.3)
                          //     :
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppColors.darkBlue,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Text(
                              'MESSAGE',
                              style: TextStyle(
                                  color: AppColors.lightBlue3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              // sortBy = 'date';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: AppColors.darkBlue,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'ADMIN',
                                    style: TextStyle(
                                        color: AppColors.lightBlue3,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.5),
                                    backgroundColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'admin', user);
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: AppColors.getActiveBtn(
                                        _themeProvider.isDarkModeEnabled)
                                    .withOpacity(0.3),
                                border: Border.all(
                                  color: AppColors.darkBlue,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'MODERATOR',
                                    style: TextStyle(
                                        color: AppColors.lightBlue3,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.5),
                                    backgroundColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'moderator', user);
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: AppColors.darkBlue,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                child: Container(
                                  child: Text(
                                    'MEMBER',
                                    style: TextStyle(
                                        color: AppColors.lightBlue3,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    barrierColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.5),
                                    backgroundColor: AppColors.getDetailBgColor(
                                            _themeProvider.isDarkModeEnabled)[1]
                                        .withOpacity(0.9),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return GroupPrivilegeSettings(
                                          'member', user);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        margin: EdgeInsets.only(top: 40, bottom: 0),
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          // color: sortBy == 'date'
                          //     ? context.toolsActiveBtn.withOpacity(0.3)
                          //     :
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppColors.red,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Colors.transparent),
                          child: Container(
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              // sortBy = 'date';
                            });
                          },
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );

    showDialog(context: context, child: dialog);
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getGroups();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _groups = Provider.of<GroupProvider>(context).userGroups;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.getDropShadow(_themeProvider.isDarkModeEnabled),
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Preferences',
              style: AppTextStyles.boldText24.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Enable notifications from Groups?',
                    style: AppTextStyles.regularText16.copyWith(
                        color: AppColors.getTextFieldText(
                            _themeProvider.isDarkModeEnabled)),
                  ),
                ),
                Switch.adaptive(
                  value: true,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
                  inactiveThumbColor: Colors.white,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              ..._groups.map((CombineGroupUserStream data) {
                var isAdmin = data.groupUsers
                    .firstWhere((g) => g.userId == _currentUser.id)
                    .isAdmin;
                var isModerator = data.groupUsers
                    .firstWhere((g) => g.userId == _currentUser.id)
                    .isModerator;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: custom.ExpansionTile(
                    iconColor: AppColors.lightBlue1,
                    headerBackgroundColorStart: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[0],
                    headerBackgroundColorEnd: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled)[1],
                    shadowColor: AppColors.getDropShadow(
                        _themeProvider.isDarkModeEnabled),
                    title: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.1),
                      child: Text(
                        data.group.name,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.boldText24
                            .copyWith(color: Colors.white70),
                      ),
                    ),
                    initiallyExpanded: false,
                    // onExpansionChanged: (bool isExpanded) {
                    // },
                    children: <Widget>[
                      custom.ExpansionTile(
                          iconColor: AppColors.lightBlue1,
                          headerBackgroundColorStart: Colors.transparent,
                          headerBackgroundColorEnd: Colors.transparent,
                          shadowColor: Colors.transparent,
                          title: Row(
                            children: <Widget>[
                              SizedBox(width: 3),
                              Text('Group Info',
                                  style: AppTextStyles.boldText14),
                              SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  color: AppColors.lightBlue1,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          initiallyExpanded: false,
                          children: <Widget>[Text('TODO DESCRIPTION')]),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'I am a',
                              style: AppTextStyles.regularText16.copyWith(
                                  color: AppColors.getTextFieldText(
                                      _themeProvider.isDarkModeEnabled)),
                            ),
                            Text(
                              isAdmin
                                  ? 'ADMIN'
                                  : isModerator
                                      ? 'MODERATOR'
                                      : 'MEMBER',
                              style: AppTextStyles.boldText24.copyWith(
                                color: AppColors.getInactvePrayerMenu(
                                  _themeProvider.isDarkModeEnabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'My Notifications',
                              style: AppTextStyles.boldText14,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Divider(
                                color: AppColors.darkBlue,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                'Enable notifications for New Prayers for this group?',
                                style: AppTextStyles.regularText16.copyWith(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled)),
                              ),
                            ),
                            Switch.adaptive(
                              value: true,
                              activeColor: Colors.white,
                              activeTrackColor: AppColors.lightBlue4,
                              inactiveThumbColor: Colors.white,
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                'Enable notifications for Prayer Updates for this group?',
                                style: AppTextStyles.regularText16.copyWith(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled)),
                              ),
                            ),
                            Switch.adaptive(
                              value: true,
                              activeColor: Colors.white,
                              activeTrackColor: AppColors.lightBlue4,
                              inactiveThumbColor: Colors.white,
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                      !isAdmin
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      'Notify me when new members joins this group',
                                      style: AppTextStyles.regularText16
                                          .copyWith(
                                              color: AppColors.getTextFieldText(
                                                  _themeProvider
                                                      .isDarkModeEnabled)),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: false,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.lightBlue4,
                                    inactiveThumbColor: Colors.white,
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      !isAdmin
                          ? Container()
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      'Notify me of membership requests',
                                      style: AppTextStyles.regularText16
                                          .copyWith(
                                              color: AppColors.getTextFieldText(
                                                  _themeProvider
                                                      .isDarkModeEnabled)),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: false,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.lightBlue4,
                                    inactiveThumbColor: Colors.white,
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                            ),
                      !isAdmin
                          ? Container()
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      'Notify me of flagged prayers',
                                      style: TextStyle(
                                          color: AppColors.getTextFieldText(
                                              _themeProvider.isDarkModeEnabled),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: false,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.lightBlue4,
                                    inactiveThumbColor: Colors.white,
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                            ),
                      !isAdmin
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      'Invite',
                                      style: TextStyle(
                                          color: AppColors.getInactvePrayerMenu(
                                              _themeProvider.isDarkModeEnabled),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.darkBlue,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      isAdmin
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: GestureDetector(
                                onTap: null,
                                child: Text(
                                  'Send an invite to join group',
                                  style: TextStyle(
                                      color: AppColors.lightBlue3,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            )
                          : !data.groupUsers
                                  .firstWhere(
                                      (g) => g.userId == _currentUser.id)
                                  .isModerator
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: GestureDetector(
                                    onTap: null,
                                    child: Text(
                                      'Send an invite to join group',
                                      style: TextStyle(
                                          color: AppColors.lightBlue3,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                )
                              : Container(),
                      !isAdmin
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 80.0),
                              child: custom.ExpansionTile(
                                iconColor: AppColors.lightBlue4,
                                headerBackgroundColorStart: Colors.transparent,
                                headerBackgroundColorEnd: Colors.transparent,
                                shadowColor: Colors.transparent,
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          'Members | ${data.groupUsers.length}',
                                          style: TextStyle(
                                              color: AppColors
                                                  .getInactvePrayerMenu(
                                                      _themeProvider
                                                          .isDarkModeEnabled),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: AppColors.getCardBorder(
                                              _themeProvider.isDarkModeEnabled),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                initiallyExpanded: false,
                                // onExpansionChanged: (bool isExpanded) {
                                // },
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        ...data.groupUsers.map(
                                          (user) => GestureDetector(
                                            onTap: () => _showAlert(user),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5.0),
                                              padding: EdgeInsets.all(15.0),
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .getTextFieldBgColor(
                                                        _themeProvider
                                                            .isDarkModeEnabled),
                                                border: Border.all(
                                                  color: AppColors.getCardBorder(
                                                      _themeProvider
                                                          .isDarkModeEnabled),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    // userData
                                                    //     .singleWhere(
                                                    //         (user) =>
                                                    //             user.id ==
                                                    //             id)
                                                    //     .fullName
                                                    'TODO'.toUpperCase(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .lightBlue3,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                  Text(
                                                    data.groupUsers
                                                            .firstWhere((g) =>
                                                                g.userId ==
                                                                _currentUser.id)
                                                            .isAdmin
                                                        ? 'ADMIN'
                                                        : data.groupUsers
                                                                .firstWhere((g) =>
                                                                    g.userId ==
                                                                    _currentUser
                                                                        .id)
                                                                .isModerator
                                                            ? 'MODERATOR'
                                                            : 'MEMBER'
                                                                .toUpperCase(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .getInactvePrayerMenu(
                                                                _themeProvider
                                                                    .isDarkModeEnabled),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      GestureDetector(
                        onTap: () =>
                            _themeProvider.changeTheme(ThemeMode.system),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: AppColors.red,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                            child: Text(
                              'LEAVE',
                              style: AppTextStyles.boldText20
                                  .copyWith(color: AppColors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      !isAdmin
                          ? Container()
                          : Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20.0),
                              width: double.infinity,
                              child: OutlineButton(
                                child: Text(
                                  'DELETE',
                                  style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                borderSide: BorderSide(color: AppColors.red),
                                onPressed: () => print(''),
                              ),
                            )
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
