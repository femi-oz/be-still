import 'dart:io';

import 'package:be_still/utils/essentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets/input_field.dart';

class CreateGroupForm extends StatelessWidget {
  final groupNameController;
  final locationController;
  final organizationController;
  final descriptionController;
  final Function setOption;
  final option;
  final formKey;
  final Function(bool) allowAutoJoin;
  final bool isEdit;
  final bool autoValidate;
  final bool autoJoin;

  CreateGroupForm(
      {this.groupNameController,
      this.locationController,
      this.organizationController,
      this.descriptionController,
      this.setOption,
      this.option,
      this.formKey,
      this.allowAutoJoin,
      this.autoValidate,
      this.autoJoin,
      this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      // ignore: deprecated_member_use
      autovalidate: autoValidate,
      child: Column(
        children: [
          CustomInput(
            // textkey: GlobalKey<FormFieldState>(),
            controller: groupNameController,
            label: 'Group Name*',
            keyboardType: TextInputType.text,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),

          // CustomInput(
          //   // textkey: GlobalKey<FormFieldState>(),
          //   controller: emailController,
          //   label: 'Email*',
          //   isEmail: true,
          //   keyboardType: TextInputType.emailAddress,
          //   isRequired: true,
          //   showSuffix: false,
          // ),
          SizedBox(height: 12.0),
          CustomInput(
            // textkey: GlobalKey<FormFieldState>(),
            controller: locationController,
            label: 'Location*',
            keyboardType: TextInputType.text,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            // textkey: GlobalKey<FormFieldState>(),
            controller: organizationController,
            label: 'Church Association',
            isRequired: false,
            keyboardType: TextInputType.text,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            // textkey: GlobalKey<FormFieldState>(),
            controller: descriptionController,
            label: 'Purpose',
            maxLines: 4,
            textInputAction: TextInputAction.done,
            isRequired: false,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  'Require admin approval to join group?',
                  style: AppTextStyles.regularText15.copyWith(
                    color: AppColors.lightBlue4,
                  ),
                ),
              ),
              Platform.isIOS
                  ? CupertinoSwitch(
                      value: autoJoin,
                      activeColor: AppColors.lightBlue4,
                      trackColor: Colors.grey[400],
                      onChanged: allowAutoJoin,
                    )
                  : Switch(
                      value: autoJoin,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.lightBlue4,
                      inactiveThumbColor: Colors.white,
                      onChanged: allowAutoJoin,
                    ),
            ],
          ),
          // SizedBox(height: 30.0),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     // Container(
          //     //   height: 30,
          //     //   decoration: BoxDecoration(
          //     //     color: option == GroupType.normal
          //     //         ? AppColors.activeButton.withOpacity(0.3)
          //     //         : Colors.transparent,
          //     //     border: Border.all(
          //     //       color: AppColors.cardBorder,
          //     //       width: 1,
          //     //     ),
          //     //     borderRadius: BorderRadius.circular(5),
          //     //   ),
          //     //   child: OutlinedButton(
          //     //       style: ButtonStyle(
          //     //         side: MaterialStateProperty.all<BorderSide>(
          //     //             BorderSide(color: AppColors.lightBlue4)),
          //     //       ),
          //     //       child: Container(
          //     //         child: Text(
          //     //           'NORMAL',
          //     //           style: TextStyle(
          //     //               color: AppColors.lightBlue3,
          //     //               fontSize: 14,
          //     //               fontWeight: FontWeight.w500),
          //     //         ),
          //     //       ),
          //     //       onPressed: () => this.setOption(GroupType.normal)),
          //     // ),
          //     // Container(
          //     //   height: 30,
          //     //   decoration: BoxDecoration(
          //     //     color: option == GroupType.private
          //     //         ? AppColors.activeButton.withOpacity(0.5)
          //     //         : Colors.transparent,
          //     //     border: Border.all(
          //     //       color: AppColors.cardBorder,
          //     //       width: 1,
          //     //     ),
          //     //     borderRadius: BorderRadius.circular(5),
          //     //   ),
          //     //   child: OutlinedButton(
          //     //       style: ButtonStyle(
          //     //         side: MaterialStateProperty.all<BorderSide>(
          //     //             BorderSide(color: AppColors.lightBlue4)),
          //     //       ),
          //     //       child: Padding(
          //     //         padding: const EdgeInsets.symmetric(
          //     //             horizontal: 5.0, vertical: 5),
          //     //         child: Text(
          //     //           'PRIVATE',
          //     //           style: TextStyle(
          //     //               color: AppColors.lightBlue3,
          //     //               fontSize: 14,
          //     //               fontWeight: FontWeight.w500),
          //     //         ),
          //     //       ),
          //     //       onPressed: () => this.setOption(GroupType.private)),
          //     // ),
          //     // Container(
          //     //   height: 30,
          //     //   decoration: BoxDecoration(
          //     //     color: option == GroupType.feed
          //     //         ? AppColors.activeButton.withOpacity(0.5)
          //     //         : Colors.transparent,
          //     //     border: Border.all(
          //     //       color: AppColors.cardBorder,
          //     //       width: 1,
          //     //     ),
          //     //     borderRadius: BorderRadius.circular(5),
          //     //   ),
          //     //   child: OutlinedButton(
          //     //       style: ButtonStyle(
          //     //         side: MaterialStateProperty.all<BorderSide>(
          //     //             BorderSide(color: AppColors.lightBlue4)),
          //     //       ),
          //     //       child: Padding(
          //     //         padding: const EdgeInsets.symmetric(
          //     //             horizontal: 5.0, vertical: 5),
          //     //         child: Text(
          //     //           'FEED',
          //     //           style: TextStyle(
          //     //               color: AppColors.lightBlue3,
          //     //               fontSize: 14,
          //     //               fontWeight: FontWeight.w500),
          //     //         ),
          //     //       ),
          //     //       onPressed: () => this.setOption(GroupType.feed)),
          //     // ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
