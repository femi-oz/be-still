import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
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
  final bool showPrayerctions;
  final bool searchMode;
  final Function onSearchChange;
  final Function switchSearchMode;
  final TextEditingController searchController;
  CustomAppBar(
      {Key key,
      this.formKey,
      this.showPrayerctions = true,
      this.onSearchChange,
      this.switchSearchMode,
      this.searchMode,
      this.searchController})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void _searchPrayer(String value) async {
    widget.onSearchChange(value);
    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value);
  }

  void _clearSearchField() async {
    widget.onSearchChange('');
    widget.searchController.text = '';
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
      leadingWidth: widget.showPrayerctions ? 120 : 60,
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
          SizedBox(width: widget.showPrayerctions ? 15 : 0),
          widget.showPrayerctions
              ? InkWell(
                  onTap: () => setState(
                      () => widget.switchSearchMode(!widget.searchMode)),
                  child: Icon(
                    AppIcons.bestill_search,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  ),
                )
              : Container(),
          SizedBox(width: widget.showPrayerctions ? 15 : 0),
          widget.showPrayerctions
              ? InkWell(
                  onTap: () => _openFilter(Settings.isDarkMode),
                  child: Icon(
                    AppIcons.bestill_tools,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  ),
                )
              : Container(),
        ],
      ),
      title: widget.searchMode
          ? Row(
              children: [
                Expanded(
                  child: Form(
                    key: widget.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: CustomInput(
                      controller: widget.searchController,
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
                    AppIcons.bestill_close,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  ),
                  onPressed: () => setState(
                    () {
                      _clearSearchField();
                      widget.switchSearchMode(!widget.searchMode);
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
