import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:be_still/src/widgets/input_field.dart';

class CreateGroupForm extends StatefulWidget {
  final groupNameController;

  final cityController;

  final stateController;

  final organizationController;

  final descriptionController;

  String option;

  CreateGroupForm({
    this.groupNameController,
    this.cityController,
    this.stateController,
    this.organizationController,
    this.descriptionController,
    this.option,
  });

  @override
  _CreateGroupFormState createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          CustomInput(
            controller: widget.groupNameController,
            label: 'Group Name*',
            textInputAction: TextInputAction.done,
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.cityController,
            label: 'City*',
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.stateController,
            label: 'State*',
            isRequired: true,
            showSuffix: false,
          ),
          SizedBox(height: 12.0),
          CustomInput(
            controller: widget.organizationController,
            label: 'Organization / Church Association',
            isRequired: false,
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
                  color: widget.option == 'normal'
                      ? context.toolsActiveBtn.withOpacity(0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.inputFieldBorder,
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
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () => setState(() => widget.option = 'normal'),
                ),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == 'private'
                      ? context.toolsActiveBtn.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.inputFieldBorder,
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
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () => setState(() => widget.option = 'private'),
                ),
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: widget.option == 'feed'
                      ? context.toolsActiveBtn.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.inputFieldBorder,
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
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () => setState(() => widget.option = 'feed'),
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
