import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/group_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/create_group/widgets/create_group_form.dart';
import 'package:be_still/screens/create_group/widgets/create_group_succesful.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = '/create-group';

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String _option = GroupType.normal;
  int _step = 1;
  AppController appController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    final group =
        Provider.of<GroupProviderV2>(context, listen: false).currentGroup;

    final isEdit = Provider.of<GroupProviderV2>(context, listen: false).isEdit;
    _groupNameController.text = isEdit ? group.name ?? '' : '';
    _locationController.text = isEdit ? group.location ?? '' : '';
    _descriptionController.text = isEdit ? group.purpose ?? '' : '';
    _organizationController.text = isEdit ? group.organization ?? '' : '';
    _requireAdminApproval = isEdit ? group.requireAdminApproval ?? false : true;
    super.initState();
  }

  _setOption(selectedOption) {}

  String newGroupId = '';

  void _save(bool isEdit, GroupDataModel group) async {
    setState(() => _autoValidate = true);
    try {
      if (!_formKey.currentState!.validate()) return null;
      _formKey.currentState!.save();

      BeStilDialog.showLoading(context);

      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;

      final fullName =
          '${(_user.firstName ?? '') + ' ' + (_user.lastName ?? '')}';
      bool isCompleted = false;

      if (!isEdit) {
        isCompleted = await Provider.of<GroupProviderV2>(context, listen: false)
            .createGroup(
          _groupNameController.text,
          _descriptionController.text,
          fullName,
          _organizationController.text,
          _locationController.text,
          GroupType.private,
          _requireAdminApproval,
        );
      } else {
        isCompleted = await Provider.of<GroupProviderV2>(context, listen: false)
            .editGroup(
                group.id ?? '',
                _groupNameController.text,
                _descriptionController.text,
                _requireAdminApproval,
                _organizationController.text,
                _locationController.text,
                group.type ?? GroupType.private);
      }
      if (isCompleted) {
        await Provider.of<PrayerProviderV2>(context, listen: false)
            .setGroupPrayers(group.id ?? '');
        setState(() {
          newGroupId = group.id ?? '';
          _step++;
        });
      }
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  Future<void> onCancel() async {
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'CANCEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Are you sure you want to cancel?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        appController.setCurrentPage(3, true, 12);
                        Navigator.pop(context);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Discard Changes',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Resume Editing',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<bool> _onWillPop() async {
    AppController appController = Get.find();
    appController.setCurrentPage(3, true, 12);
    return false;
  }

  bool _requireAdminApproval = true;
  bool _autoValidate = false;
  Widget build(BuildContext context) {
    final groupProviderV2GroupProviderV2 =
        Provider.of<GroupProviderV2>(context, listen: false);
    final groupData = groupProviderV2GroupProviderV2.currentGroup;
    bool isValid = _groupNameController.text.isNotEmpty ||
        // _emailController.text.isNotEmpty ||
        _locationController.text.isNotEmpty;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            // appBar: CustomAppBar(
            //   showPrayerActions: false,
            // ),
            body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage),
                alignment: Alignment.bottomCenter,
                fit: BoxFit.fitWidth),
          ),
          child: Container(
            height: Get.height,
            color: AppColors.backgroundColor[0].withOpacity(0.5),
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top + 20),
                _step == 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              left: 20,
                            ),
                            child: InkWell(
                              child: Text(
                                'CANCEL',
                                style: AppTextStyles.boldText18
                                    .copyWith(color: AppColors.grey),
                              ),
                              onTap: isValid
                                  ? () => onCancel()
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      // Navigator.pop(context);
                                      appController.setCurrentPage(3, true, 12);
                                    },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              right: 20,
                            ),
                            child: InkWell(
                                child: Text(
                                    groupProviderV2GroupProviderV2.isEdit
                                        ? 'SAVE'
                                        : 'ADD',
                                    style: AppTextStyles.boldText18
                                        .copyWith(color: Colors.blue)),
                                onTap: () {
                                  if (_step == 1) {
                                    _save(groupProviderV2GroupProviderV2.isEdit,
                                        groupData);
                                  } else {
                                    NavigationService.instance.goHome(0);
                                  }
                                }),
                          ),
                        ],
                      )
                    : Container(),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _step == 1
                          ? CreateGroupForm(
                              requireAdminApproval: _requireAdminApproval,
                              onChangeAdminApproval: (val) {
                                setState(() {
                                  _requireAdminApproval = val;
                                });
                              },
                              isEdit: groupProviderV2GroupProviderV2.isEdit,
                              formKey: _formKey,
                              locationController: _locationController,
                              descriptionController: _descriptionController,
                              groupNameController: _groupNameController,
                              // emailController: _emailController,
                              option: _option,
                              organizationController: _organizationController,
                              setOption: _setOption,
                              autoValidate: _autoValidate,
                            )
                          : GroupCreated(
                              _groupNameController.text,
                              groupProviderV2GroupProviderV2.isEdit,
                              newGroupId),
                      SizedBox(height: 30.0),
                      // _step == 1
                      //     ? Container(
                      //         child: Column(
                      //           children: <Widget>[
                      //             Container(
                      //               width: double.infinity,
                      //               margin: EdgeInsets.only(bottom: 20),
                      //               decoration: BoxDecoration(
                      //                 gradient: LinearGradient(
                      //                   begin: Alignment.centerLeft,
                      //                   end: Alignment.centerRight,
                      //                   colors: [
                      //                     AppColors.lightBlue1,
                      //                     AppColors.lightBlue2,
                      //                   ],
                      //                 ),
                      //               ),
                      //               child: TextButton(
                      //                 onPressed: () {
                      // if (_step == 1) {
                      //   _save(
                      //       groupProviderV2GroupProviderV2.isEdit, groupData);
                      // } else {
                      //   NavigationService.instance.goHome(0);
                      // }
                      //                 },
                      //                 style: ButtonStyle(
                      //                   backgroundColor:
                      //                       MaterialStateProperty.all<Color>(
                      //                           Colors.transparent),
                      //                 ),
                      //                 child: Icon(AppIcons.bestill_next_arrow,
                      //                     color: AppColors.white),
                      //               ),
                      //             ),
                      //             SizedBox(height: 60.0),
                      //           ],
                      //         ),
                      //       )
                      //     : Container(),
                    ],
                  ),
                )),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
