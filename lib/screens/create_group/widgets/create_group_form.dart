import 'package:be_still/enums/group_type.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets/input_field.dart';

class CreateGroupForm extends StatefulWidget {
  final groupNameController;
  final cityController;
  final stateController;
  final organizationController;
  final descriptionController;
  final Function setOption;
  final option;
  final formKey;
  final autoValidate;
  final emailController;

  CreateGroupForm({
    this.groupNameController,
    this.cityController,
    this.stateController,
    this.organizationController,
    this.descriptionController,
    this.setOption,
    this.option,
    this.autoValidate,
    this.formKey,
    this.emailController,
  });

  @override
  _CreateGroupFormState createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  @override
  Widget build(BuildContext context) {
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
            controller: widget.emailController,
            label: 'Email*',
            keyboardType: TextInputType.emailAddress,
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
                      ? AppColors.activeButton.withOpacity(0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.cardBorder,
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
                    onPressed: () => null),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == GroupType.private
                      ? AppColors.activeButton.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.cardBorder,
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
                    onPressed: () => null),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == GroupType.feed
                      ? AppColors.activeButton.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.cardBorder,
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
                    onPressed: () => null),
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
