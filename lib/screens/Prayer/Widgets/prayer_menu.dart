import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/Widgets/find_a_group_tools.dart';
import 'package:be_still/screens/prayer/Widgets/menu_items.dart';
import 'package:be_still/screens/prayer/Widgets/prayer_tools.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';

class PrayerMenu extends StatefulWidget {
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  bool searchMode = false;
  final TextEditingController _searchController = TextEditingController();

  void _clearSearchField() async {
    _searchController.text = '';
    await Provider.of<PrayerProvider>(context, listen: false).searchPrayers('');
  }

  void _searchPrayer(String value) async {
    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value);
  }

  void _setCurrentList(
      PrayerActiveScreen activeList, CombineGroupUserStream groupData) async {
    await Provider.of<GroupProvider>(context, listen: false)
        .setCurrentGroup(groupData);
    await Provider.of<PrayerProvider>(context, listen: false)
        .setCurrentPrayerType(activeList);
    _setPrayers(groupData, activeList);
  }

  void _setPrayers(
      CombineGroupUserStream groupData, PrayerActiveScreen activeList) async {
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    var isGroupAdmin;
    if (groupData != null) {
      isGroupAdmin = groupData.groupUsers
          .firstWhere((user) => user.userId == _user.id, orElse: () => null)
          ?.isAdmin;
    }
    await Provider.of<PrayerProvider>(context, listen: false).setPrayers(
      _user.id,
      activeList,
      activeList == PrayerActiveScreen.group ? groupData.group?.id : '0',
      isGroupAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _groups = Provider.of<GroupProvider>(context).userGroups;
    final _activeList = Provider.of<PrayerProvider>(context).currentPrayerType;
    openTools() {
      showModalBottomSheet(
        context: context,
        barrierColor: context.toolsBg,
        backgroundColor: context.toolsBg,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return _activeList == PrayerActiveScreen.findGroup
              ? FindGroupTools()
              : PrayerTools();
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.dropShadow,
            offset: Offset(0.0, 0.5),
            blurRadius: 5.0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            context.prayerMenuStart,
            context.prayerMenuEnd,
          ],
        ),
      ),
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
            width: 50,
            child: IconButton(
              icon: Icon(
                AppIcons.search,
                color: context.brightBlue,
                size: 25,
              ),
              onPressed: () => setState(
                () => {
                  searchMode = !searchMode,
                },
              ),
            ),
          ),
          SizedBox(width: 15.0),
          searchMode
              ? Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: CustomInput(
                        controller: _searchController,
                        label: 'Search',
                        padding: 5.0,
                        showSuffix: false,
                        textInputAction: TextInputAction.done,
                        onTextchanged: _searchPrayer,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.brightBlue,
                        size: 25,
                      ),
                      onPressed: () => setState(
                        () {
                          _clearSearchField();
                          searchMode = !searchMode;
                        },
                      ),
                    )
                  ],
                )
              : Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        PrayerMenuItem(
                          title: 'My List',
                          isActive: _activeList == PrayerActiveScreen.personal,
                          action: () => setState(() {
                            _setCurrentList(PrayerActiveScreen.personal, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < _groups.length; i++)
                              PrayerMenuItem(
                                title: _groups[i].group.name,
                                isActive:
                                    _activeList == PrayerActiveScreen.group &&
                                        _groups[i].group.id ==
                                            Provider.of<GroupProvider>(context)
                                                .currentGroup
                                                .group
                                                .id,
                                action: () => setState(() {
                                  _setCurrentList(
                                      PrayerActiveScreen.group, _groups[i]);
                                }),
                                openTools: () => openTools(),
                              ),
                          ],
                        ),
                        PrayerMenuItem(
                          title: 'Archived',
                          isActive: _activeList == PrayerActiveScreen.archived,
                          action: () => setState(() {
                            _setCurrentList(PrayerActiveScreen.archived, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Answered',
                          isActive: _activeList == PrayerActiveScreen.answered,
                          action: () => setState(() {
                            _setCurrentList(PrayerActiveScreen.answered, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Find a Group',
                          isActive: _activeList == PrayerActiveScreen.findGroup,
                          action: () => setState(() {
                            _setCurrentList(PrayerActiveScreen.findGroup, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Create a Group +',
                          isActive:
                              _activeList == PrayerActiveScreen.createGroup,
                          action: () => setState(() {
                            _setCurrentList(
                                PrayerActiveScreen.createGroup, null);
                            Navigator.of(context).pushReplacementNamed(
                                CreateGroupScreen.routeName);
                          }),
                          openTools: () => openTools(),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
