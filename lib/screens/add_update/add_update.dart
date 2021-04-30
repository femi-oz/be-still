import 'dart:io';

import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AddUpdate extends StatefulWidget {
  static const routeName = 'update-prayer';
  @override
  _AddUpdateState createState() => _AddUpdateState();
}

class _AddUpdateState extends State<AddUpdate> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BuildContext bcontext;
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();
  bool _autoValidate = false;

  Future<void> _save(String prayerId) async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    try {
      BeStilDialog.showLoading(context);
      if (_descriptionController.text == null ||
          _descriptionController.text.trim() == '') {
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, 'You can not save empty prayers');
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .addPrayerUpdate(user.id, _descriptionController.text, prayerId);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        NavigationService.instance.goHome(0);
      }
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
    return (NavigationService.instance.goHome(0)) ?? false;
  }

  Future<void> onCancel() async {
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Are you sure you want to cancel?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRightWithFade,
                        child: PrayerDetails(),
                      ),
                    ),
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Discard Changes',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Resume Editing',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;

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
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                                color: AppColors.lightBlue5, fontSize: 16),
                          ),
                          onTap: () => _descriptionController.text.isNotEmpty
                              ? onCancel()
                              : NavigationService.instance.goHome(0)),
                      InkWell(
                        child: Text('SAVE',
                            style: TextStyle(
                                color: _descriptionController.text.isEmpty
                                    ? AppColors.lightBlue5.withOpacity(0.5)
                                    : Colors.blue)),
                        onTap: () => _descriptionController.text.isNotEmpty
                            ? _save(prayerData.prayer.id)
                            : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: [
                          Form(
                            autovalidate: _autoValidate,
                            key: _formKey,
                            child: CustomInput(
                              label: "Enter your text here",
                              controller: _descriptionController,
                              maxLines: 23,
                              isRequired: true,
                              showSuffix: false,
                              textInputAction: TextInputAction.newline,
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
                                prayerData.prayer.userId != currentUser.id
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          prayerData.prayer.createdBy,
                                          style: TextStyle(
                                              color: AppColors.lightBlue3,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : Container(),
                                ...prayerData.updates.map(
                                  (u) => Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 30),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    DateFormat(
                                                            'hh:mma | MM.dd.yyyy')
                                                        .format(u.modifiedOn),
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.dimBlue,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                          ],
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Center(
                                              child: Text(
                                                u.description,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textFieldText,
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
                                                  'Initial Prayer |',
                                                  style: TextStyle(
                                                      color: AppColors.dimBlue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  DateFormat(' MM.dd.yyyy')
                                                      .format(prayerData
                                                          .prayer.modifiedOn),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.dimBlue,
                                                      fontWeight:
                                                          FontWeight.w500),
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
                                              prayerData.prayer.description,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
