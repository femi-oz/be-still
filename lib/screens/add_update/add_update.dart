import 'dart:io';

import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../entry_screen.dart';

class AddUpdate extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final List<PrayerUpdateModel> updates;
  static const routeName = 'update-prayer';

  @override
  AddUpdate({this.prayerData, this.updates});

  @override
  _AddUpdateState createState() => _AddUpdateState();
}

class _AddUpdateState extends State<AddUpdate> {
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  BuildContext bcontext;
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();

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
      prayerId: widget.prayerData.id,
      userId: _user.id,
      title: '',
      description: _descriptionController.text,
      modifiedBy: _user.id,
      modifiedOn: DateTime.now(),
      createdBy: _user.id,
      createdOn: DateTime.now(),
    );
    try {
      BeStilDialog.showLoading(bcontext);
      await Provider.of<PrayerProvider>(context, listen: false)
          .addPrayerUpdate(prayerUpdateData);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(bcontext);
      Navigator.of(context).pushReplacementNamed(PrayerDetails.routeName);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(bcontext);
      BeStilDialog.showErrorDialog(bcontext, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(bcontext);
      BeStilDialog.showErrorDialog(bcontext, StringUtils.errorOccured);
    }
  }

  @override
  void initState() {
    // getContacts();
    super.initState();
  }

  // getContacts() async {
  //   var status = await Permission.contacts.status;
  //   if (status.isUndetermined) {
  //     await Permission.contacts.request();
  //   }
  //   if (await Permission.contacts.request().isGranted) {
  //     localContacts = await ContactsService.getContacts(withThumbnails: false);
  //   }
  // }

  // var words = [];
  // String str = '';
  // var phoneNumbers = [];

  // onTextChange(val) {
  //   setState(() {
  //     words = val.split(' ');

  //     str = words.length > 0 && words[words.length - 1].startsWith('@')
  //         ? words[words.length - 1]
  //         : '';
  //   });
  // }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EntryScreen(screenNumber: 0)))) ??
        false;
  }

  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Container(
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
                      // onTextchanged: onTextChange,
                      focusNode: _focusNode,
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
                        widget.prayerData.prayer.userId != _currentUser.id
                            ? Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  widget.prayerData.prayer.createdBy,
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
                                                .format(u.modifiedOn),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          DateFormat(' MM.dd.yyyy').format(
                                              widget.prayerData.prayer
                                                  .modifiedOn),
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
                                      widget.prayerData.prayer.description,
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
      ),
    );
  }
}
