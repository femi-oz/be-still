import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupTools extends StatefulWidget {
  final CombineGroupUserStream groupData;
  // final setCurrentIndex;
  GroupTools(
    this.groupData,
    // this.setCurrentIndex,
  );

  @override
  _GroupToolsState createState() => _GroupToolsState();
}

class _GroupToolsState extends State<GroupTools> {
  Future<void> onEditTap(CombineGroupUserStream groupData) async {
    AppCOntroller appCOntroller = Get.find();

    appCOntroller.setCurrentPage(12, true);

    // await Provider.of<MiscProvider>(context, listen: false).setIsEdit(true);
    await Provider.of<GroupProvider>(context, listen: false)
        .setCurrentGroup(groupData);
    Navigator.pop(context);
  }

  void _getPrayers(CombineGroupUserStream data) async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      // await Provider.of<GroupProvider>(context, listen: false)
      //     .setUserGroups(_user.id);
      // await Provider.of<GroupProvider>(context, listen: false)
      //     .setAllGroups(_user.id);
      // await Provider.of<PrayerProvider>(context, listen: false).setGroupPrayers(
      //   _user?.id,
      //   data.group.id,
      //   data.groupUsers.firstWhere((e) => e.userId == _user.id).isAdmin,
      // );
    } on HttpException catch (_) {
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    var currentGroupUser = widget.groupData.groupUsers
        .firstWhere((element) => element.userId == _user.id);
    return Container(
      padding: EdgeInsets.only(left: 40),
      height: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero),
                ),
                icon: Icon(
                  AppIcons.bestill_back_arrow,
                  color: AppColors.lightBlue4,
                ),
                onPressed: () => Navigator.pop(context),
                label: Text(
                  'BACK',
                  style: AppTextStyles.boldText20.copyWith(
                    color: AppColors.prayerPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          // SizedBox(height: 20),
          // LongButton(
          //   icon: Icons.settings,
          //   onPress: () {
          //     _getPrayers(Provider.of<GroupProvider>(context, listen: false)
          //         .currentGroup);
          //   },
          //   text: "View Group",
          //   backgroundColor: Settings.isDarkMode
          //       ? AppColors.backgroundColor[0]
          //       : Colors.white,
          //   textColor: AppColors.lightBlue3,
          //   onPressMore: () => null,
          // ),
          SizedBox(height: 10),
          currentGroupUser.role == GroupUserRole.admin
              ? LongButton(
                  icon: Icons.edit,
                  onPress: () => onEditTap(widget.groupData),
                  text: "Edit Group",
                  backgroundColor: Settings.isDarkMode
                      ? AppColors.backgroundColor[0]
                      : Colors.white,
                  textColor: AppColors.lightBlue3,
                  onPressMore: () => null,
                )
              : Container(),

          SizedBox(height: 10),
          LongButton(
            icon: Icons.add,
            onPress: () {
              AppCOntroller appCOntroller = Get.find();
              appCOntroller.setCurrentPage(10, true);
              Navigator.pop(context);
            },
            text: "Add a Prayer",
            backgroundColor: Settings.isDarkMode
                ? AppColors.backgroundColor[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          SizedBox(height: 10),
          LongButton(
            icon: Icons.more_vert,
            onPress: () {
              AppCOntroller appCOntroller = Get.find();

              appCOntroller.setCurrentPage(4, true);

              Navigator.pop(context);
            },
            text: "Manage Settings",
            backgroundColor: Settings.isDarkMode
                ? AppColors.backgroundColor[0]
                : Colors.white,
            textColor: AppColors.lightBlue3,
            onPressMore: () => null,
          ),
          // SizedBox(height: 10),
          // LongButton(
          //   icon: Icons.share,
          //   onPress: null,
          //   text: "Invite - Email",
          //   backgroundColor: Settings.isDarkMode
          //       ? AppColors.backgroundColor[0]
          //       : Colors.white,
          //   textColor: AppColors.lightBlue3,
          //   onPressMore: () => null,
          // ),
          // SizedBox(height: 10),
          // LongButton(
          //   icon: Icons.share,
          //   onPress: null,
          //   text: "Invite - Text",
          //   backgroundColor: Settings.isDarkMode
          //       ? AppColors.backgroundColor[0]
          //       : Colors.white,
          //   textColor: AppColors.lightBlue3,
          //   onPressMore: () => null,
          // ),
          // SizedBox(height: 10),
          // LongButton(
          //   icon: Icons.share,
          //   onPress: null,
          //   text: "Invite - QR Code",
          //   backgroundColor: Settings.isDarkMode
          //       ? AppColors.backgroundColor[0]
          //       : Colors.white,
          //   textColor: AppColors.lightBlue3,
          //   onPressMore: () => null,
          // ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
