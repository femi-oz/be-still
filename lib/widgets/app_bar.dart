import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
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
  CustomAppBar({
    Key key,
    this.switchSearchMode,
    this.isSearchMode = false,
    this.showPrayerActions = true,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController searchController = TextEditingController();
  void _searchPrayer(String value) async {
    print('got here');
    var userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;

    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value, userId);
  }

  void _clearSearchField() async {
    searchController.clear();
    _searchPrayer('');
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
                    if (searchController.text.isEmpty) {
                      widget.switchSearchMode(true);
                      Provider.of<MiscProvider>(context, listen: false)
                          .setSearchMode(true);
                      setState(() {});
                    } else {
                      _searchPrayer(searchController.text);
                      Provider.of<MiscProvider>(context, listen: false)
                          .setSearchQuery(searchController.text);
                    }
                  },
                  child: Icon(
                    AppIcons.bestill_search,
                    color: AppColors.bottomNavIconColor,
                    size: 18,
                  ),
                )
              : Container(),
          SizedBox(width: 15),
          widget.showPrayerActions && !widget.isSearchMode
              ? GestureDetector(
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
      title: widget.isSearchMode
          ? Container(
              width: MediaQuery.of(context).size.width * 2,
              child: Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: searchController,
                      label: 'Search',
                      padding: 5.0,
                      showSuffix: false,
                      textInputAction: TextInputAction.done,
                      submitForm: () => _searchPrayer(searchController.text),

                      // onTextchanged: _searchPrayer,
                    ),
                    // ),
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
              pageTitle,
              style: TextStyle(
                color: AppColors.bottomNavIconColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
      actions: <Widget>[
        widget.showPrayerActions && !widget.isSearchMode
            ? IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: AppColors.white,
                ),
                onPressed: null,
              )
            : Container(),
      ],
    );
  }
}
