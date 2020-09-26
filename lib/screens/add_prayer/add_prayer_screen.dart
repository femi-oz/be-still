import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/Widgets/name_recognition_one.dart';
import 'package:be_still/screens/prayer/widgets/prayer_card.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/add_prayer_menu.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  final bool isEdit;

  final PrayerModel prayer;

  @override
  AddPrayer({this.isEdit, this.prayer});
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
        groupId: '0',
        userId: _user.id,
        description: _descriptionController.text,
        status: 'Active',
        modifiedBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
        modifiedOn: DateTime.now(),
        type: '',
        createdBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
        createdOn: DateTime.now(),
      );
      showModalBottomSheet(
        context: context,
        barrierColor: context.toolsBg.withOpacity(0.5),
        backgroundColor: context.toolsBg.withOpacity(0.9),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NameRecognitionMenuOne(
              prayer: prayerData, scafoldKey: _scaffoldKey);
        },
      );
    } else {
      prayerData = PrayerModel(
        title: widget.prayer.title,
        isAnswer: widget.prayer.isAnswer,
        groupId: widget.prayer.groupId,
        userId: widget.prayer.userId,
        description: _descriptionController.text,
        status: widget.prayer.status,
        modifiedBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
        modifiedOn: DateTime.now(),
        type: widget.prayer.type,
        createdBy: widget.prayer.createdBy,
        createdOn: widget.prayer.createdOn,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .editprayer(prayerData, widget.prayer.id);

      Navigator.of(context).pushNamed(
        PrayerDetails.routeName,
        arguments: PrayerDetailsRouteArguments(
          widget.prayer.id,
        ),
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
                colors: [
                  context.mainBgStart,
                  context.mainBgEnd,
                ],
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
