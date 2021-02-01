import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/screens/Prayer/Widgets/prayer_tools.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final formKey;
  CustomAppBar({Key key, this.formKey})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool searchMode = false;
  final TextEditingController _searchController = TextEditingController();

  void _searchPrayer(String value) async {
    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value);
  }

  void _clearSearchField() async {
    _searchController.text = '';
    await Provider.of<PrayerProvider>(context, listen: false).searchPrayers('');
  }

  _openFilter(bool isDark) {
    showModalBottomSheet(
      context: context,
      barrierColor: AppColors.detailBackgroundColor[1],
      backgroundColor: AppColors.detailBackgroundColor[1],
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PrayerFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = Provider.of<MiscProvider>(context).pageTitle;
    List<NotificationModel> notifications =
        Provider.of<NotificationProvider>(context).notifications;

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
      leadingWidth: 120,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 20),
          InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(NotificationsScreen.routeName),
            child: notifications.length == 0
                ? Icon(
                    Icons.notifications_none,
                    color: AppColors.bottomNavIconColor,
                    size: 24,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications,
                        color: AppColors.red,
                        size: 24,
                      ),
                      Text(
                        notifications.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () => setState(() => searchMode = !searchMode),
            child: Icon(
              AppIcons.search,
              color: AppColors.bottomNavIconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () => _openFilter(Settings.isDarkMode),
            child: Icon(
              Icons.filter_list_alt,
              color: AppColors.bottomNavIconColor,
              size: 24,
            ),
          ),
        ],
      ),
      title: searchMode
          ? Row(
              children: [
                Expanded(
                  child: Form(
                    key: widget.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: CustomInput(
                      controller: _searchController,
                      label: 'Search',
                      padding: 5.0,
                      showSuffix: false,
                      textInputAction: TextInputAction.done,
                      onTextchanged: _searchPrayer,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
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
          : Text(
              pageTitle,
              style: TextStyle(
                color: AppColors.bottomNavIconColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return InkWell(
              child: Icon(
                AppIcons.menu,
                color: AppColors.bottomNavIconColor,
              ),
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
