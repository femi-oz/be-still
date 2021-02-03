import 'dart:io';

import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/widgets/name_recognition_one.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../entry_screen.dart';

class AddUpdate extends StatefulWidget {
  final PrayerModel prayer;
  final List<PrayerUpdateModel> updates;
  static const routeName = 'update-prayer';

  @override
  AddUpdate({this.prayer, this.updates});

  @override
  _AddUpdateState createState() => _AddUpdateState();
}

class _AddUpdateState extends State<AddUpdate> {
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  BuildContext bcontext;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _save() async {
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    PrayerUpdateModel prayerUpdateData;
    prayerUpdateData = PrayerUpdateModel(
      prayerId: widget.prayer.id,
      userId: _user.id,
      title: '',
      description: _descriptionController.text,
      modifiedBy: _user.id,
      modifiedOn: DateTime.now(),
      createdBy: _user.id,
      createdOn: DateTime.now(),
    );
    // showModalBottomSheet(
    //   context: context,
    //   barrierColor: AppColors.detailBackgroundColor[1].withOpacity(0.5),
    //   backgroundColor: AppColors.detailBackgroundColor[1].withOpacity(0.9),
    //   isScrollControlled: true,
    //   builder: (BuildContext context) {
    //     return NameRecognitionMenuOne(
    //       isUpdate: true,
    //       prayerUpdate: prayerUpdateData,
    //       scafoldKey: _scaffoldKey,
    //     );
    //   },
    // );
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .addPrayerUpdate(prayerUpdateData);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _onWillPop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EntryScreen(screenNumber: 0),
            ))) ??
        false;
  }

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return Scaffold(
      body: SafeArea(
        child:
            // Scaffold(
            //   body:
            Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
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
                            color: AppColors.lightBlue5, fontSize: 16),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    InkWell(
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                            color: AppColors.lightBlue5, fontSize: 16),
                      ),
                      onTap: () => _save(),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Form(
                  autovalidate: _autoValidate,
                  key: _formKey,
                  child: CustomInput(
                    label: "Enter your text here",
                    controller: _descriptionController,
                    maxLines: 23,
                    isRequired: true,
                    showSuffix: false,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.darkBlue2,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.prayer.userId != _currentUser.id
                          ? Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
                                widget.prayer.createdBy,
                                style: TextStyle(
                                    color: AppColors.lightBlue3,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                      ...widget.updates.map(
                        (u) => Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          DateFormat('hh:mma | MM.dd.yyyy')
                                              .format(u.createdOn),
                                          style: TextStyle(
                                              color: AppColors.dimBlue,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.darkBlue2,
                                      thickness: 1,
                                    ),
                                  ),
                                  // TODO
                                  // ...u.tags
                                  //     .map(
                                  //       (t) => Container(
                                  //         margin: EdgeInsets.only(left: 10),
                                  //         child: Row(
                                  //           children: <Widget>[
                                  //             Text(
                                  //               t.toUpperCase(),
                                  //               style: TextStyle(
                                  //                 color: AppColors.red,
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     )
                                  //     .toList()
                                ],
                              ),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      u.description,
                                      style: TextStyle(
                                        color: AppColors.textFieldText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        height: 2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 30),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Initial Prayer Request |',
                                        style: TextStyle(
                                            color: AppColors.dimBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        DateFormat(' MM.dd.yyyy')
                                            .format(widget.prayer.createdOn),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.dimBlue,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.darkBlue2,
                                    thickness: 1,
                                  ),
                                ),
                                // TODO
                                // ...prayer.tags
                                //     .map(
                                //       (t) => Container(
                                //         margin: EdgeInsets.only(left: 10),
                                //         child: Text(
                                //           t.toUpperCase(),
                                //           style: TextStyle(
                                //             fontSize: 12,
                                //             color: AppColors.red,
                                //           ),
                                //         ),
                                //       ),
                                //     )
                                //     .toList(),
                              ],
                            ),
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 200,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 20),
                                child: Center(
                                  child: Text(
                                    widget.prayer.description,
                                    style: TextStyle(
                                      color: AppColors.textFieldText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      height: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ),
      ),
    );
  }
}
