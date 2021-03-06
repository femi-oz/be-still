import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/screens/groups/widgets/filter_options.dart';
import 'package:be_still/screens/prayer/widgets/filter_options.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function? switchSearchMode;
  final bool isSearchMode;
  final bool showPrayerActions;
  final bool isGroup;
  final bool showOnlyTitle;
  final GlobalKey? globalKey;
  final GlobalKey? searchGlobalKey;
  CustomAppBar({
    Key? key,
    this.switchSearchMode,
    this.isSearchMode = false,
    this.isGroup = false,
    this.showOnlyTitle = false,
    this.showPrayerActions = true,
    this.globalKey,
    this.searchGlobalKey,
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
  }

  void _searchPrayer(String value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchQuery(value);
    await Provider.of<PrayerProviderV2>(context, listen: false)
        .searchPrayers(value, userId ?? '');
  }

  void _clearSearchField() async {
    _searchController.clear();
    _searchPrayer('');
    _searchGroupPrayer('');
  }

  void _searchGroupPrayer(String value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchQuery(value);
    await Provider.of<PrayerProviderV2>(context, listen: false)
        .searchGroupPrayers(value, userId ?? '');
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
          Provider.of<MiscProviderV2>(context, listen: false).searchQuery;
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

  int get getCount {
    final notifications =
        Provider.of<NotificationProviderV2>(context).notifications;
    return notifications.length;
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = Provider.of<MiscProviderV2>(context).pageTitle;

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
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                widget.showPrayerActions
                    ? InkWell(
                        onTap: () {
                          if (_searchController.text.isEmpty &&
                              widget.switchSearchMode != null) {
                            widget.switchSearchMode!(true);
                            Provider.of<MiscProviderV2>(context, listen: false)
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
                                child: Icon(AppIcons.bestill_search,
                                    key: widget.searchGlobalKey,
                                    color: AppColors.bottomNavIconColor,
                                    size: 18))))
                    : SizedBox(height: 30, width: 30),
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
                                child: Icon(AppIcons.bestill_tools,
                                    key: widget.globalKey,
                                    color: AppColors.bottomNavIconColor,
                                    size: 18))))
                    : Container()
              ]),
          Expanded(
            child: !widget.showOnlyTitle && widget.isSearchMode
                ? Row(
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: CustomInput(
                          controller: _searchController,
                          label: 'Search',
                          padding: 5.0,
                          showSuffix: false,
                          isGroup: widget.isGroup,
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
                            if (widget.switchSearchMode != null) {
                              widget.isGroup
                                  ? _clearGroupSearchField()
                                  : _clearSearchField();

                              widget.switchSearchMode!(false);
                              Provider.of<MiscProviderV2>(context,
                                      listen: false)
                                  .setSearchMode(false);
                              Provider.of<MiscProviderV2>(context,
                                      listen: false)
                                  .setSearchQuery('');
                              // setState(() {});
                            }
                          },
                        ),
                      )
                    ],
                  )
                : widget.showOnlyTitle || widget.showPrayerActions
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              pageTitle,
                              style: TextStyle(
                                color: AppColors.bottomNavIconColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
          ),
          !widget.isSearchMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          AppController appController = Get.find();
                          appController.setCurrentPage(
                              14, false, appController.currentPage);
                        },
                        child: Center(
                            child:
                                Stack(alignment: Alignment.center, children: [
                          Icon(
                              getCount != 0
                                  ? Icons.notifications
                                  : Icons.notifications_none,
                              size: 30,
                              color: getCount != 0
                                  ? AppColors.red
                                  : AppColors.white),
                          Padding(
                              padding: EdgeInsets.only(
                                  right: getCount == 1
                                      ? 2
                                      : getCount > 9
                                          ? 1
                                          : 0),
                              child: Text(
                                  getCount < 1 ? '' : getCount.toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600)))
                        ]))),
                  ],
                )
              : Container()
        ]));
  }
}
