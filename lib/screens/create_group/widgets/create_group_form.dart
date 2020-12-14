import 'package:be_still/enums/group_type.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:provider/provider.dart';

class CreateGroupForm extends StatefulWidget {
  final groupNameController;
  final cityController;
  final stateController;
  final organizationController;
  final descriptionController;
  GroupType option;
  final formKey;
  final autoValidate;

  CreateGroupForm({
    this.groupNameController,
    this.cityController,
    this.stateController,
    this.organizationController,
    this.descriptionController,
    this.option,
    this.autoValidate,
    this.formKey,
  });

  @override
  _CreateGroupFormState createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Form(
      key: widget.formKey,
      autovalidate: widget.autoValidate,
      child: Column(
        children: [
          CustomInput(
            controller: widget.groupNameController,
            label: 'Group Name*',
            keyboardType: TextInputType.text,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.cityController,
            label: 'City*',
            keyboardType: TextInputType.text,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.stateController,
            label: 'State*',
            keyboardType: TextInputType.text,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.organizationController,
            label: 'Organization / Church Association',
            isRequired: false,
            keyboardType: TextInputType.text,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.descriptionController,
            label: 'Group Short Description',
            maxLines: 4,
            textInputAction: TextInputAction.done,
            isRequired: false,
            showSuffix: false,
          ),
          SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == GroupType.normal
                      ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                          .withOpacity(0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.getCardBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.transparent),
                  child: Container(
                    child: Text(
                      'NORMAL',
                      style: TextStyle(
                          color: AppColors.lightBlue3,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () =>
                      setState(() => widget.option = GroupType.normal),
                ),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == GroupType.private
                      ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                          .withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.getCardBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: Text(
                      'PRIVATE',
                      style: TextStyle(
                          color: AppColors.lightBlue3,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () =>
                      setState(() => widget.option = GroupType.private),
                ),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == GroupType.feed
                      ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                          .withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.getCardBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: Text(
                      'FEED',
                      style: TextStyle(
                          color: AppColors.lightBlue3,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () =>
                      setState(() => widget.option = GroupType.feed),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.0),
          Text(
            'PRIVATE groups setting will hide the group from general search, admin & moderators will need to send invites directly to add new members',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }
}
