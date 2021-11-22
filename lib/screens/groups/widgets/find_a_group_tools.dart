import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
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
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    await Provider.of<GroupProvider>(context, listen: false)
        .searchAllGroups(_groupNameController.text, userId);
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: <Widget>[
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ADVANCE SEARCH',
                  style: TextStyle(
                      color: AppColors.lightBlue3,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CustomInput(
                  // textkey: GlobalKey<FormFieldState>(),
                  controller: _groupNameController,
                  label: 'Group Name',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  textkey: GlobalKey<FormFieldState>(),
                  controller: _locationController,
                  label: 'Location',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  textkey: GlobalKey<FormFieldState>(),
                  controller: _organizationController,
                  label: 'Church Association',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  textkey: GlobalKey<FormFieldState>(),
                  controller: _adminNameController,
                  label: 'Admin Name',
                  isRequired: false,
                  showSuffix: false,
                ),
                SizedBox(height: 12.0),
                CustomInput(
                  textkey: GlobalKey<FormFieldState>(),
                  controller: _descriptionController,
                  label: 'Purpose',
                  isRequired: false,
                  showSuffix: false,
                ),
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
          ),
        ],
      ),
    );
  }
}
