import 'package:be_still/enums/status.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/screens/prayer/widgets/filter_options.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final formKey;
  final Function switchSearchMode;
  // final TextEditingController searchController;
  CustomAppBar({Key key, this.formKey, this.switchSearchMode})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchMode = false;
  void _searchPrayer(String value) async {
    var options =
        Provider.of<PrayerProvider>(context, listen: false).filterOptions;
    var userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    if (options.contains(Status.archived)) {
      await Provider.of<PrayerProvider>(context, listen: false).searchPrayers(
          value,
          Provider.of<SettingsProvider>(context, listen: false)
              .settings
              .archiveSortBy,
          userId);
    } else {
      await Provider.of<PrayerProvider>(context, listen: false).searchPrayers(
          value,
          Provider.of<SettingsProvider>(context, listen: false)
              .settings
              .defaultSortBy,
          userId);
    }
  }

  void _clearSearchField() async {
    searchController.clear();
    _searchPrayer('');
  }

  _openFilter(bool isDark) {
    showModalBottomSheet(
      context: context,
      barrierColor: AppColors.addPrayerBg.withOpacity(0.8),
      backgroundColor: AppColors.addPrayerBg.withOpacity(0.8),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PrayerFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = Provider.of<MiscProvider>(context).pageTitle;
    List<PushNotificationModel> notifications =
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
                    AppIcons.bestill_notifications,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        AppIcons.bestill_notifications,
                        color: AppColors.red,
                        size: 18,
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
          SizedBox(width: 15),
          InkWell(
            onTap: () {
              widget.switchSearchMode(true);
              setState(() => isSearchMode = true);
            },
            child: Icon(
              AppIcons.bestill_search,
              color: AppColors.bottomNavIconColor,
              size: 18,
            ),
          ),
          SizedBox(width: 15),
          InkWell(
            onTap: () => _openFilter(Settings.isDarkMode),
            child: Icon(
              AppIcons.bestill_tools,
              color: AppColors.bottomNavIconColor,
              size: 18,
            ),
          )
        ],
      ),
      title: isSearchMode
          ? Row(
              children: [
                Expanded(
                  child: Form(
                    key: widget.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: CustomInput(
                      controller: searchController,
                      label: 'Search',
                      padding: 5.0,
                      showSuffix: false,
                      textInputAction: TextInputAction.done,
                      onTextchanged: _searchPrayer,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  child: Icon(
                    AppIcons.bestill_close,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  ),
                  onTap: () => setState(
                    () {
                      _clearSearchField();
                      widget.switchSearchMode(false);
                      setState(() => isSearchMode = false);
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
                AppIcons.bestill_main_menu,
                size: 18,
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
