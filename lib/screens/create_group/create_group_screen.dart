import 'package:be_still/Models/prayer.model.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:be_still/screens/create_group/widgets/create_group_form.dart';
import 'package:be_still/screens/create_group/widgets/create_group_succesful.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:be_still/utils/app_theme.dart';

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
  String _option = 'normal';
  int _step = 1;
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _cityController = TextEditingController();
    final TextEditingController _stateController = TextEditingController();
    final TextEditingController _organizationController =
        TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(provider: _app),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.mainBgStart,
              context.mainBgEnd,
            ],
          ),
          image: DecorationImage(
            image: AssetImage(_app.isDarkModeEnabled
                ? 'assets/images/background-pattern-dark.png'
                : 'assets/images/background-pattern.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.895,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      context.prayerMenuStart,
                      context.prayerMenuEnd,
                    ],
                  ),
                ),
                child: Text(
                  'Create a Group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.settingsHeader,
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
                                    context.authBtnStart,
                                    context.authBtnEnd,
                                  ],
                                ),
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  print(_step);
                                  if (_step > 1) {
                                    Navigator.of(context).pushReplacementNamed(
                                        PrayerScreen.routeName);
                                  } else {
                                    setState(() {
                                      _step++;
                                    });
                                  }
                                },
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: context.offWhite,
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
