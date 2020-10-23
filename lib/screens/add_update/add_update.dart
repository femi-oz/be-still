import 'package:be_still/models/prayer.model.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/widgets/name_recognition_one.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      title: '',
      description: _descriptionController.text,
      modifiedBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
      modifiedOn: DateTime.now(),
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
          isUpdate: true,
          prayerUpdate: prayerUpdateData,
          scafoldKey: _scaffoldKey,
        );
      },
    );
  }

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return SafeArea(
      child: Scaffold(
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
                      color: context.prayerDetailsCardBorder,
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
                                    color: context.brightBlue,
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
                                              color: context.dimBlue,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: context.prayerDetailsCardBorder,
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
                                  //                 color: context.prayerCardTags,
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
                                        color: context.inputFieldText,
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
                                            color: context.dimBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        DateFormat(' MM.dd.yyyy')
                                            .format(widget.prayer.createdOn),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: context.dimBlue,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: context.prayerDetailsCardBorder,
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
                                //             color: context.prayerCardTags,
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
                                      color: context.inputFieldText,
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
      ),
    );
  }
}
