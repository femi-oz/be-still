import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_tools.dart';
import 'package:be_still/screens/groups/widgets/find_a_group_tools.dart';
import 'package:be_still/screens/prayer/Widgets/menu_items.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      PrayerType activeList, CombineGroupUserStream groupData) async {
    await Provider.of<GroupProvider>(context, listen: false)
        .setCurrentGroup(groupData);
    await Provider.of<PrayerProvider>(context, listen: false)
        .setCurrentPrayerType(activeList);
  }

  @override
  Widget build(BuildContext context) {
    final _groups = Provider.of<GroupProvider>(context).userGroups;
    final _activeList = Provider.of<PrayerProvider>(context).currentPrayerType;
    openFilter() {
      showModalBottomSheet(
        context: context,
        barrierColor: AppColors.detailBackgroundColor[1],
        backgroundColor: AppColors.detailBackgroundColor[1],
        isScrollControlled: true,
        builder: (BuildContext context) {
          return _activeList == PrayerType.findGroup
              ? FindGroupTools()
              : PrayerFilters();
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.dropShadow,
            offset: Offset(0.0, 0.5),
            blurRadius: 5.0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: AppColors.prayerMenu,
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
                AppIcons.bestill_search,
                color: AppColors.lightBlue3,
                size: 25,
              ),
              onPressed: () => setState(
                () => searchMode = !searchMode,
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
                        AppIcons.bestill_close,
                        color: AppColors.lightBlue3,
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
                          isActive: _activeList == PrayerType.userPrayers,
                          action: () => setState(() {
                            _setCurrentList(PrayerType.userPrayers, null);
                          }),
                          openTools: () => openFilter(),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < _groups.length; i++)
                              PrayerMenuItem(
                                title: _groups[i].group.name,
                                isActive: _activeList == PrayerType.group &&
                                    _groups[i].group.id ==
                                        Provider.of<GroupProvider>(context)
                                            .currentGroup
                                            .group
                                            .id,
                                action: () => setState(() {
                                  _setCurrentList(PrayerType.group, _groups[i]);
                                }),
                                openTools: () => openFilter(),
                              ),
                          ],
                        ),
                        PrayerMenuItem(
                          title: 'Archived',
                          isActive: _activeList == PrayerType.archived,
                          action: () => setState(() {
                            _setCurrentList(PrayerType.archived, null);
                          }),
                          openTools: () => openFilter(),
                        ),
                        PrayerMenuItem(
                          title: 'Answered',
                          isActive: _activeList == PrayerType.answered,
                          action: () => setState(() {
                            _setCurrentList(PrayerType.answered, null);
                          }),
                          openTools: () => openFilter(),
                        ),
                        PrayerMenuItem(
                          title: 'Find a Group',
                          isActive: _activeList == PrayerType.findGroup,
                          action: () => setState(() {
                            _setCurrentList(PrayerType.findGroup, null);
                          }),
                          openTools: () => openFilter(),
                        ),
                        PrayerMenuItem(
                          title: 'Create a Group +',
                          isActive: _activeList == PrayerType.createGroup,
                          action: () => setState(() {
                            _setCurrentList(PrayerType.createGroup, null);
                            Navigator.of(context).pushReplacementNamed(
                                CreateGroupScreen.routeName);
                          }),
                          openTools: () => openFilter(),
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
