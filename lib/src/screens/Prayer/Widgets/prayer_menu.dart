import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Enums/prayer_list.enum.dart';
import 'package:be_still/src/screens/Prayer/Widgets/prayer_tools.dart';
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
  final searchController;

  @override
  PrayerMenu(this.setCurrentList, this.activeList, this.groupId,
      this.searchController);
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
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
          SizedBox(width: 10.0),
          searchMode
              ? Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: CustomInput(
                        controller: widget.searchController,
                        label: 'Search',
                        padding: 5.0,
                        submitForm: (_) => setState(
                          () => {
                            searchMode = !searchMode,
                          },
                        ),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () => setState(() {
                                widget.setCurrentList(
                                    PrayerListType.personal, null);
                              }),
                              child: Text(
                                'My List',
                                style: TextStyle(
                                  color: widget.activeList ==
                                          PrayerListType.personal
                                      ? context.brightBlue
                                      : context.prayerMenuInactive,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              height: 15,
                              child:
                                  widget.activeList == PrayerListType.personal
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: context.brightBlue,
                                          ),
                                          padding: EdgeInsets.all(0),
                                          onPressed: () => openTools(),
                                        )
                                      : Container(),
                            ),
                          ],
                        ),
                        ...GROUP_DATA
                            .where((gl) => gl.members.contains(_app.user.id))
                            .map(
                              (g) => Row(children: [
                                SizedBox(width: 40.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () => setState(() {
                                        widget.setCurrentList(
                                            PrayerListType.group, g.id);
                                      }),
                                      child: Text(
                                        g.name,
                                        style: TextStyle(
                                          color: widget.activeList ==
                                                      PrayerListType.group &&
                                                  widget.groupId == g.id
                                              ? context.brightBlue
                                              : context.prayerMenuInactive,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.all(0),
                                      height: 15,
                                      child: widget.activeList ==
                                                  PrayerListType.group &&
                                              widget.groupId == g.id
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.more_horiz,
                                                color: context.brightBlue,
                                              ),
                                              padding: EdgeInsets.all(0),
                                              onPressed: () => openTools(),
                                            )
                                          : Container(),
                                    )
                                  ],
                                ),
                              ]),
                            ),
                        SizedBox(width: 40.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () => setState(() {
                                widget.setCurrentList(
                                    PrayerListType.archived, null);
                              }),
                              child: Text(
                                'Archived',
                                style: TextStyle(
                                  color: widget.activeList ==
                                          PrayerListType.archived
                                      ? context.brightBlue
                                      : context.prayerMenuInactive,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              height: 15,
                              child:
                                  widget.activeList == PrayerListType.archived
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: context.brightBlue,
                                          ),
                                          padding: EdgeInsets.all(0),
                                          onPressed: () => openTools(),
                                        )
                                      : Container(),
                            ),
                          ],
                        ),
                        SizedBox(width: 40.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () => setState(() {
                                widget.setCurrentList(
                                    PrayerListType.answered, null);
                              }),
                              child: Text(
                                'Answered',
                                style: TextStyle(
                                  color: widget.activeList ==
                                          PrayerListType.answered
                                      ? context.brightBlue
                                      : context.prayerMenuInactive,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              height: 15,
                              child:
                                  widget.activeList == PrayerListType.answered
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: context.brightBlue,
                                          ),
                                          padding: EdgeInsets.all(0),
                                          onPressed: () => openTools(),
                                        )
                                      : Container(),
                            ),
                          ],
                        ),
                        SizedBox(width: 20.0)
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
