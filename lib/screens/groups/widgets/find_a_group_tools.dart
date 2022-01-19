import 'dart:io';

import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindGroupTools extends StatefulWidget {
  @override
  FindGroupTools();

  @override
  _FindGroupToolsState createState() => _FindGroupToolsState();
}

class _FindGroupToolsState extends State<FindGroupTools> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();

  void _searchGroup() async {
    try {
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      if (_groupNameController.text.isNotEmpty ||
          _locationController.text.isNotEmpty ||
          _adminNameController.text.isNotEmpty ||
          _organizationController.text.isNotEmpty ||
          _descriptionController.text.isNotEmpty) {
        await Provider.of<GroupProvider>(context, listen: false)
            .advanceSearchAllGroups(
                _groupNameController.text,
                userId ?? '',
                _locationController.text,
                _organizationController.text,
                _adminNameController.text,
                _descriptionController.text);
      }
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor[0],
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: 40,
                right: 20,
                left: 20,
                top: MediaQuery.of(context).padding.top + 80),
            child: Column(children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(AppIcons.bestill_back_arrow,
                      color: AppColors.lightBlue5),
                  label: Text(
                    'BACK',
                    style: TextStyle(
                      color: AppColors.lightBlue5,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'ADVANCED SEARCH',
                    style: TextStyle(
                        color: AppColors.lightBlue3,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 30.0),
                  CustomInput(
                    // textkey: GlobalKey<FormFieldState>(),
                    controller: _groupNameController,
                    label: 'Group Name',
                    isRequired: false,
                    showSuffix: false,
                  ),
                  SizedBox(height: 12.0),
                  CustomInput(
                    // textkey: GlobalKey<FormFieldState>(),
                    controller: _locationController,
                    label: 'Location',
                    isRequired: false,
                    showSuffix: false,
                  ),

                  SizedBox(height: 12.0),
                  CustomInput(
                    // textkey: GlobalKey<FormFieldState>(),
                    controller: _organizationController,
                    label: 'Church',
                    isRequired: false,
                    showSuffix: false,
                  ),
                  SizedBox(height: 12.0),
                  CustomInput(
                    // textkey: GlobalKey<FormFieldState>(),
                    controller: _adminNameController,
                    label: 'Admin Name',
                    isRequired: false,
                    showSuffix: false,
                  ),
                  SizedBox(height: 12.0),
                  CustomInput(
                    // textkey: GlobalKey<FormFieldState>(),
                    controller: _descriptionController,
                    label: 'Purpose',
                    isRequired: false,
                    showSuffix: false,
                  ),
                  // SizedBox(height: 30.0),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Container(
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: _option == 'normal'
                  //             ? AppColors.activeButton.withOpacity(0.3)
                  //             : Colors.transparent,
                  //         border: Border.all(
                  //           color: AppColors.cardBorder,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(5),
                  //       ),
                  //       child: OutlinedButton(
                  //         style: ButtonStyle(
                  //           side: MaterialStateProperty.all<BorderSide>(
                  //               BorderSide(color: Colors.transparent)),
                  //         ),
                  //         child: Container(
                  //           child: Text(
                  //             'NORMAL',
                  //             style: TextStyle(
                  //                 color: AppColors.lightBlue3,
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w500),
                  //           ),
                  //         ),
                  //         onPressed: () => setState(() => _option = 'normal'),
                  //       ),
                  //     ),
                  //     SizedBox(width: 50.0),
                  //     Container(
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: _option == 'feed'
                  //             ? AppColors.activeButton.withOpacity(0.5)
                  //             : Colors.transparent,
                  //         border: Border.all(
                  //           color: AppColors.cardBorder,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(5),
                  //       ),
                  //       child: OutlinedButton(
                  //         style: ButtonStyle(
                  //           side: MaterialStateProperty.all<BorderSide>(
                  //               BorderSide(color: Colors.transparent)),
                  //         ),
                  //         child: Padding(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 5.0, vertical: 5),
                  //           child: Text(
                  //             'FEED',
                  //             style: TextStyle(
                  //                 color: AppColors.lightBlue3,
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w500),
                  //           ),
                  //         ),
                  //         onPressed: () => setState(() => _option = 'feed'),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 60.0),
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(BorderSide(
                            color: Settings.isDarkMode
                                ? AppColors.darkBlue
                                : AppColors.lightBlue4)),
                      ),
                      child: Container(
                        child: Text(
                          'SEARCH',
                          style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onPressed: () {
                        _searchGroup();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
