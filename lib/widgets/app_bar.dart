import 'dart:ui';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/groups/widgets/filter_options.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/screens/prayer/widgets/filter_options.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function switchSearchMode;
  final bool isSearchMode;
  final bool showPrayerActions;
  final bool isGroup;
  final bool showOnlyTitle;
  final GlobalKey globalKey;
  CustomAppBar({
    Key key,
    this.switchSearchMode,
    this.isSearchMode = false,
    this.isGroup = false,
    this.showOnlyTitle = false,
    this.showPrayerActions = true,
    this.globalKey,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController _searchController = TextEditingController();
  final _searchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print(widget.showOnlyTitle);
  }

  void _searchPrayer(String value) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    await Provider.of<MiscProvider>(context, listen: false)
        .setSearchQuery(value);
    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value, userId);
  }

  void _clearSearchField() async {
    _searchController.clear();
    _searchPrayer('');
  }

  void _searchGroupPrayer(String value) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    await Provider.of<MiscProvider>(context, listen: false)
        .setSearchQuery(value);
    await Provider.of<GroupPrayerProvider>(context, listen: false)
        .searchPrayers(value, userId);
  }

  void _clearGroupSearchField() async {
    _searchController.clear();
    _searchGroupPrayer('');
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final searchQuery =
          Provider.of<MiscProvider>(context, listen: false).searchQuery;
      setState(() {
        if (searchQuery != '') {
          _searchController.text = searchQuery;
        }
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  _openFilter(bool isDark) {
    final dialog = Dialog(
        insetPadding: EdgeInsets.all(40),
        backgroundColor: AppColors.prayerCardBgColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.darkBlue),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: PrayerFilters());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  _openGroupFilter(bool isDark) {
    final dialog = Dialog(
        insetPadding: EdgeInsets.all(40),
        backgroundColor: AppColors.prayerCardBgColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.darkBlue),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: GroupPrayerFilters());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  int get notificationCount {
    final notifications =
        Provider.of<NotificationProvider>(context).notifications;
    return notifications.length;
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = Provider.of<MiscProvider>(context).pageTitle;

    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: AppColors.appBarBackground,
          ),
        ),
      ),
      centerTitle: true,
      leadingWidth: widget.showPrayerActions && !widget.isSearchMode ? 100 : 53,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 20),
          widget.showPrayerActions
              ? InkWell(
                  onTap: () {
                    if (_searchController.text.isEmpty) {
                      widget.switchSearchMode(true);
                      Provider.of<MiscProvider>(context, listen: false)
                          .setSearchMode(true);
                      setState(() {});
                    } else {
                      widget.isGroup
                          ? _searchGroupPrayer(_searchController.text)
                          : _searchPrayer(_searchController.text);
                    }
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    child: Center(
                      child: Icon(
                        AppIcons.bestill_search,
                        color: AppColors.bottomNavIconColor,
                        size: 18,
                      ),
                    ),
                  ),
                )
              : Container(),
          widget.showPrayerActions && !widget.isSearchMode
              ? SizedBox(width: 5)
              : Container(),
          widget.showPrayerActions && !widget.isSearchMode
              ? InkWell(
                  onTap: () => widget.isGroup
                      ? _openGroupFilter(Settings.isDarkMode)
                      : _openFilter(Settings.isDarkMode),
                  child: Container(
                    height: 30,
                    width: 30,
                    child: Center(
                      child: Icon(
                        AppIcons.bestill_tools,
                        key: widget.globalKey,
                        color: AppColors.bottomNavIconColor,
                        size: 18,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      title: !widget.showOnlyTitle && widget.isSearchMode
          ? Container(
              width: MediaQuery.of(context).size.width * 2,
              child: Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _searchController,
                      label: 'Search',
                      padding: 5.0,
                      showSuffix: false,
                      textInputAction: TextInputAction.done,
                      isSearch: true,
                      textkey: _searchKey,
                      unfocus: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: Icon(
                          AppIcons.bestill_close,
                          color: AppColors.bottomNavIconColor,
                          size: 18,
                        ),
                      ),
                    ),
                    onTap: () => setState(
                      () {
                        widget.isGroup
                            ? _clearGroupSearchField()
                            : _clearSearchField();

                        widget.switchSearchMode(false);
                        Provider.of<MiscProvider>(context, listen: false)
                            .setSearchMode(false);
                        Provider.of<MiscProvider>(context, listen: false)
                            .setSearchQuery('');

                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
            )
          : Text(
              widget.showOnlyTitle
                  ? pageTitle
                  : widget.showPrayerActions
                      ? pageTitle
                      : '',
              style: TextStyle(
                color: AppColors.bottomNavIconColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
      actions: <Widget>[
        !widget.isSearchMode
            ? GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                ),
                child: Container(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                              notificationCount != 0
                                  ? Icons.notifications
                                  : Icons.notifications_none,
                              size: 30,
                              color: notificationCount != 0
                                  ? AppColors.red
                                  : AppColors.white),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
                            ),
                          ),
                        ),
                        notificationCount != 0
                            ? Padding(
                                padding: EdgeInsets.only(
                                    right: notificationCount == 1
                                        ? 2
                                        : notificationCount > 9
                                            ? 1
                                            : 0),
                                child: Text(notificationCount.toString(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600)),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
