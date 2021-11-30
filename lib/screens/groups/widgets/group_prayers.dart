import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/group_prayer_card.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupPrayers extends StatefulWidget {
  final Function switchSearchMode;
  final bool isSearchMode;
  GroupPrayers(
    this.switchSearchMode,
    this.isSearchMode,
  );
  @override
  _GroupPrayersState createState() => _GroupPrayersState();
}

class _GroupPrayersState extends State<GroupPrayers> {
  Future<bool> _onWillPop() async {
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final group =
            Provider.of<GroupProvider>(context, listen: false).currentGroup;
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle((group.group?.name ?? '').toUpperCase());
        await Provider.of<GroupPrayerProvider>(context, listen: false)
            .setHiddenPrayer(_user.id);
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<GroupPrayerProvider>(context).filteredPrayers;
    final _hiddenPrayers =
        Provider.of<GroupPrayerProvider>(context, listen: false).hiddenPrayers;
    data.forEach((element) {
      _hiddenPrayers.forEach((x) {
        if (element.groupPrayer.prayerId.contains(x.prayerId)) {
          data = data
              .where(
                  (y) => y.groupPrayer.prayerId != element.groupPrayer.prayerId)
              .toList();
        }
      });
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          isGroup: true,
          showPrayerActions: true,
          isSearchMode: widget.isSearchMode,
          switchSearchMode: (bool val) => widget.switchSearchMode(val),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 20),
          height: MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.backgroundImage),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                data.length == 0
                    ? Container(
                        padding: EdgeInsets.all(60),
                        child: Text(
                          'You don\'t have any prayer in your List.',
                          style: AppTextStyles.regularText13,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            ...data
                                .map((e) => GestureDetector(
                                    onTap: () async {
                                      await Provider.of<GroupPrayerProvider>(
                                              context,
                                              listen: false)
                                          .setPrayer(e.groupPrayer.id);
                                      Future.delayed(
                                              Duration(milliseconds: 400))
                                          .then((value) {
                                        AppCOntroller appCOntroller =
                                            Get.find();

                                        appCOntroller.setCurrentPage(9, true);
                                      });
                                    },
                                    child: GroupPrayerCard(
                                      prayerData: e,
                                      timeago: '',
                                    )))
                                .toList(),
                          ],
                        ),
                      ),
                // currentPrayerType == Status.archived ||
                //         currentPrayerType == Status.answered
                //     ? Container()
                //     :
                // groupUser.role == GroupUserRole.admin
                //     ?
                LongButton(
                  onPress: () {
                    Provider.of<GroupPrayerProvider>(context, listen: false)
                        .setEditMode(false);
                    Provider.of<GroupPrayerProvider>(context, listen: false)
                        .setEditPrayer(null);
                    AppCOntroller appCOntroller = Get.find();

                    appCOntroller.setCurrentPage(10, true);
                  },
                  text: 'Add New Prayer',
                  backgroundColor: Settings.isDarkMode
                      ? AppColors.backgroundColor[1]
                      : AppColors.lightBlue3,
                  textColor:
                      Settings.isDarkMode ? AppColors.lightBlue3 : Colors.white,
                  icon: AppIcons.bestill_add,
                ),
                // : Container(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
