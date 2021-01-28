import 'package:be_still/enums/group_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/create_group/widgets/create_group_form.dart';
import 'package:be_still/screens/create_group/widgets/create_group_succesful.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = '/create-group';
  final activeList;
  final List<PrayerModel> prayers;
  final groupId;

  @override
  CreateGroupScreen({this.activeList, this.groupId, this.prayers});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  GroupType _option = GroupType.normal;
  int _step = 1;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  void _save() async {
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) {
      // showInSnackBar('Please, enter your prayer');
      return;
    }
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    GroupModel groupData = GroupModel(
      name: _groupNameController.text,
      location: '${_cityController.text}, ${_stateController.text}',
      organization: _organizationController.text,
      description: _descriptionController.text,
      email: _emailController.text,
      status: Status.active,
      isPrivate: _option == GroupType.private,
      isFeed: _option == GroupType.feed,
      modifiedBy: _user.id,
      modifiedOn: DateTime.now(),
      createdBy: _user.id,
      createdOn: DateTime.now(),
    );
    await Provider.of<GroupProvider>(context, listen: false).addGroup(groupData,
        _user.id, '${_user.firstName} ${_user.lastName}', _user.email);
    setState(() {
      _step++;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
        image: DecorationImage(
          image: AssetImage(Settings.isDarkMode
              ? 'assets/images/background-pattern-dark.png'
              : 'assets/images/background-pattern.png'),
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        child: Column(
          children: <Widget>[
            CustomSectionHeder('Create a Group'),
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _step == 1
                      ? CreateGroupForm(
                          formKey: _formKey,
                          autoValidate: _autoValidate,
                          cityController: _cityController,
                          descriptionController: _descriptionController,
                          groupNameController: _groupNameController,
                          emailController: _emailController,
                          option: _option,
                          organizationController: _organizationController,
                          stateController: _stateController,
                        )
                      : GroupCreated(_groupNameController.text),
                  SizedBox(height: 30.0),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.lightBlue1,
                                AppColors.lightBlue2,
                              ],
                            ),
                          ),
                          child: FlatButton(
                            onPressed: () {
                              print(_step);
                              if (_step == 1) {
                                _save();
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => new EntryScreen(),
                                  ),
                                );
                                // Navigator.of(context).pushReplacementNamed(
                                //     EntryScreen.routeName);
                              }
                            },
                            color: Colors.transparent,
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppColors.offWhite1,
                            ),
                          ),
                        ),
                        SizedBox(height: 60.0),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    ));
  }
}
