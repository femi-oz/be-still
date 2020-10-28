import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/widgets/name_recognition_one.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/add_prayer_menu.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  final bool isEdit;
  final PrayerModel prayer;
  final GroupModel group;
  final bool isGroup;

  @override
  AddPrayer({this.isEdit, this.prayer, this.group, this.isGroup});
  _AddPrayerState createState() => _AddPrayerState();
}

class _AddPrayerState extends State<AddPrayer> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _save() async {
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) {
      // showInSnackBar('Please, enter your prayer');
      return;
    }
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    PrayerModel prayerData;
    if (!widget.isEdit) {
      prayerData = PrayerModel(
          title: '',
          isAnswer: false,
          groupId: widget.isGroup ? widget.group.id : '0',
          userId: _user.id,
          description: _descriptionController.text,
          status: 'Active',
          modifiedBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
          modifiedOn: DateTime.now(),
          type: '',
          createdBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
          createdOn: DateTime.now(),
          hideFromAllMembers: false,
          hideFromMe: false,
          isInappropriate: false);
      showModalBottomSheet(
        context: context,
        barrierColor: context.toolsBg.withOpacity(0.5),
        backgroundColor: context.toolsBg.withOpacity(0.9),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NameRecognitionMenuOne(
              isUpdate: false,
              prayer: prayerData,
              scafoldKey: _scaffoldKey,
              isGroup: widget.isGroup);
        },
      );
    } else {
      await Provider.of<PrayerProvider>(context, listen: false)
          .editprayer(_descriptionController.text, widget.prayer.id);

      Navigator.of(context).pushNamed(
        PrayerDetails.routeName,
        arguments: PrayerDetailsRouteArguments(
            id: widget.prayer.id, isGroup: widget.isGroup),
      );
    }
  }

  @override
  void initState() {
    _descriptionController.text =
        widget.isEdit ? widget.prayer.description : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.getBackgroudColor(
                    _themeProvider.isDarkModeEnabled),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                              color: context.toolsBackBtn, fontSize: 16),
                        ),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      InkWell(
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                                color: context.toolsBackBtn, fontSize: 16),
                          ),
                          onTap: () => _save()),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  Form(
                    autovalidate: _autoValidate,
                    key: _formKey,
                    child: CustomInput(
                      label: 'Prayer description',
                      controller: _descriptionController,
                      maxLines: 23,
                      isRequired: true,
                      showSuffix: false,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: context.brightBlue2,
                    ),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      barrierColor: context.toolsBg.withOpacity(0.5),
                      backgroundColor: context.toolsBg.withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return AddPrayerMenu();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class RouteArguments {
//   final String id;
//   // final String groupId;

//   RouteArguments(
//     this.id,
//     // this.groupId,
//   );
// }
