import 'package:be_still/enums/group_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/create_group/widgets/create_group_form.dart';
import 'package:be_still/screens/create_group/widgets/create_group_succesful.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = 'create-group';
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
      status: Status.active,
      isPrivate: _option == GroupType.private,
      isFeed: _option == GroupType.feed,
      modifiedBy: _user.id,
      modifiedOn: DateTime.now(),
      createdBy: _user.id,
      createdOn: DateTime.now(),
    );
    await Provider.of<GroupProvider>(context, listen: false)
        .addGroup(groupData, _user.id, '${_user.firstName} ${_user.lastName}');
    setState(() {
      _step++;
    });
  }

  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
          ),
          image: DecorationImage(
            image: AssetImage(_themeProvider.isDarkModeEnabled
                ? 'assets/images/background-pattern-dark.png'
                : 'assets/images/background-pattern.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: AppColors.getPrayerMenu(
                        _themeProvider.isDarkModeEnabled),
                  ),
                ),
                child: Text(
                  'Create a Group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.offWhite2,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Container(
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
                              option: _option,
                              organizationController: _organizationController,
                              stateController: _stateController,
                            )
                          : GroupCreated(),
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
                                    Navigator.of(context).pushReplacementNamed(
                                        PrayerScreen.routeName);
                                  }
                                },
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.offWhite1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
