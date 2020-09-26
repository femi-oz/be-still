import 'package:be_still/data/group.data.dart';
import 'package:be_still/enums/prayer_list.enum.dart';
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
  final setCurrentList;

  final activeList;

  final groupId;
  final onTextchanged;
  final searchController;
  final clearSearchField;

  @override
  PrayerMenu({
    this.setCurrentList,
    this.activeList,
    this.groupId,
    this.onTextchanged,
    this.searchController,
    this.clearSearchField,
  });
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  bool searchMode = false;
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    openTools() {
      showModalBottomSheet(
        context: context,
        barrierColor: context.toolsBg,
        backgroundColor: context.toolsBg,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return widget.activeList == PrayerActiveScreen.findGroup
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
                        controller: widget.searchController,
                        label: 'Search',
                        padding: 5.0,
                        showSuffix: false,
                        textInputAction: TextInputAction.done,
                        onTextchanged: widget.onTextchanged,
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
                          widget.clearSearchField();
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
                          isActive:
                              widget.activeList == PrayerActiveScreen.personal,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerActiveScreen.personal, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        // TODO
                        // ...groupData
                        //     .where((gl) => gl.members.contains(_currentUser.id))
                        //     .map(
                        //       (g) => Row(children: [
                        //         PrayerMenuItem(
                        //           title: g.name,
                        //           isActive: widget.activeList ==
                        //                   PrayerActiveScreen.group &&
                        //               widget.groupId == g.id,
                        //           action: () => setState(() {
                        //             widget.setCurrentList(
                        //                 PrayerActiveScreen.group, g.id);
                        //           }),
                        //           openTools: () => openTools(),
                        //         ),
                        //       ]),
                        //     ),
                        PrayerMenuItem(
                          title: 'Archived',
                          isActive:
                              widget.activeList == PrayerActiveScreen.archived,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerActiveScreen.archived, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Answered',
                          isActive:
                              widget.activeList == PrayerActiveScreen.answered,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerActiveScreen.answered, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Find a Group',
                          isActive:
                              widget.activeList == PrayerActiveScreen.findGroup,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerActiveScreen.findGroup, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Create a Group +',
                          isActive: widget.activeList ==
                              PrayerActiveScreen.createGroup,
                          action: () => setState(() {
                            widget.setCurrentList(
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
