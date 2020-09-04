import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Enums/prayer_list.enum.dart';
import 'package:be_still/src/screens/Prayer/Widgets/menu_items.dart';
import 'package:be_still/src/screens/Prayer/Widgets/prayer_tools.dart';
import 'package:be_still/src/screens/create_group/create_group_screen.dart';
import 'package:be_still/src/widgets/app_icons_icons.dart';
import 'package:be_still/src/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../../../widgets/Theme/app_theme.dart';

class PrayerMenu extends StatefulWidget {
  final setCurrentList;

  final activeList;

  final groupId;
  var onTextchanged;

  @override
  PrayerMenu(
      {this.setCurrentList,
      this.activeList,
      this.groupId,
      // this.searchController,
      this.onTextchanged});
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  final TextEditingController searchController = TextEditingController();

  bool searchMode = false;
  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    openTools() {
      showModalBottomSheet(
        context: context,
        barrierColor: context.toolsBg,
        backgroundColor: context.toolsBg,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return PrayerTools();
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
                        controller: searchController,
                        label: 'Search',
                        padding: 5.0,
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
                        () => {
                          searchMode = !searchMode,
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
                          showIcon:
                              widget.activeList == PrayerListType.personal,
                          showActiveColor:
                              widget.activeList == PrayerListType.personal,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerListType.personal, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        ...groupData
                            .where((gl) => gl.members.contains(_app.user.id))
                            .map(
                              (g) => Row(children: [
                                PrayerMenuItem(
                                  title: g.name,
                                  showIcon: widget.activeList ==
                                          PrayerListType.group &&
                                      widget.groupId == g.id,
                                  showActiveColor: widget.activeList ==
                                          PrayerListType.group &&
                                      widget.groupId == g.id,
                                  action: () => setState(() {
                                    widget.setCurrentList(
                                        PrayerListType.group, g.id);
                                  }),
                                  openTools: () => openTools(),
                                ),
                              ]),
                            ),
                        PrayerMenuItem(
                          title: 'Archived',
                          showIcon:
                              widget.activeList == PrayerListType.archived,
                          showActiveColor:
                              widget.activeList == PrayerListType.archived,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerListType.archived, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Answered',
                          showIcon:
                              widget.activeList == PrayerListType.answered,
                          showActiveColor:
                              widget.activeList == PrayerListType.answered,
                          action: () => setState(() {
                            widget.setCurrentList(
                                PrayerListType.answered, null);
                          }),
                          openTools: () => openTools(),
                        ),
                        PrayerMenuItem(
                          title: 'Create a Group +',
                          showIcon: false,
                          showActiveColor: true,
                          action: () => setState(() {
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
// []
