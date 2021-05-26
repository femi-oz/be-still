import 'dart:io';

import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

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
  final _prayerKey = GlobalKey();

  List<String> tags = [];
  String tagText = '';
  List<Contact> contacts = [];
  List<PrayerTagModel> oldTags = [];
  String backupText;
  String _oldDescription = '';
  TextPainter painter;
  bool showNoContact = false;
  String displayName = '';
  List<String> tagList = [];

  @override
  void initState() {
    _oldDescription = _descriptionController.text;
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    if (Settings.enabledContactPermission) {
      final _localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      localContacts = _localContacts.where((e) => e.displayName != null);
    }
  }

  void _onTextChange(val) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    try {
      tags = val.split(new RegExp(r"\s"));

      setState(() {
        tagText = tags.length > 0 && tags[tags.length - 1].startsWith('@')
            ? tags[tags.length - 1]
            : '';
      });
      tagList.clear();
      localContacts.forEach((s) {
        if (('@' + s.displayName)
            .trim()
            .toLowerCase()
            .contains(tagText.trim().toLowerCase())) {
          tagList.add(s.displayName);
        }
      });

      painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: val,
        ),
      );
      painter.layout();
    } catch (e) {
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), userId, 'ADD_PRAYER_UPDATE/screen/onTextChange_tag');
    }
  }

  Future<void> _onTagSelected(s) async {
    tagText = '';
    String tmpText = s.displayName.substring(0, s.displayName.length);

    String controllerText = _descriptionController.text
        .substring(0, _descriptionController.text.indexOf('@'));

    controllerText += tmpText;
    _descriptionController.text = controllerText;
    _descriptionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descriptionController.text.length));

    setState(() {
      _descriptionController.selection =
          TextSelection.collapsed(offset: _descriptionController.text.length);
    });

    if (!contacts.map((e) => e.identifier).contains(s.identifier)) {
      contacts = [...contacts, s];
    }
  }

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
        PlatformException e = PlatformException(
            code: 'custom', message: 'You can not save empty prayers');

        BeStilDialog.showErrorDialog(context, e, user, null);
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .addPrayerUpdate(user.id, _descriptionController.text, prayerId);

        contacts.forEach((s) {
          if (!_descriptionController.text.contains(s.displayName)) {
            s.displayName = '';
          }
          if (!contacts.map((e) => e.identifier).contains(s.identifier)) {
            contacts = [...contacts, s];
          }
        });

        if (contacts.length > 0) {
          await Provider.of<PrayerProvider>(context, listen: false)
              .addPrayerTag(
                  contacts, user, _descriptionController.text, prayerId);
        }
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);

        Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false);
      }
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<bool> _onWillPop() async {
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
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
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'CANCEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Are you sure you want to cancel?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          EntryScreen.routeName,
                          (Route<dynamic> route) => false);
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.grey.withOpacity(0.5),
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
    // _descriptionController.selection = TextSelection.fromPosition(
    //     TextPosition(offset: _descriptionController.text.length));
    // print(_descriptionController.selection.toString());

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
                            style: AppTextStyles.boldText18
                                .copyWith(color: AppColors.grey),
                          ),
                          onTap: () => _descriptionController.text.isNotEmpty
                              ? onCancel()
                              : Navigator.of(context).pushNamedAndRemoveUntil(
                                  EntryScreen.routeName,
                                  (Route<dynamic> route) => false)),
                      InkWell(
                        child: Text('SAVE',
                            style: AppTextStyles.boldText18.copyWith(
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
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Form(
                              autovalidate: _autoValidate,
                              key: _formKey,
                              child: CustomInput(
                                textkey: _prayerKey,
                                label: "Enter your text here",
                                controller: _descriptionController,
                                maxLines: 23,
                                isRequired: true,
                                showSuffix: false,
                                textInputAction: TextInputAction.newline,
                                focusNode: _focusNode,
                                onTextchanged: (val) => _onTextChange(val),
                                isSearch: false,
                              ),
                            ),
                            tagText.length > 0
                                ? Positioned(
                                    // padding: EdgeInsets.only(
                                    //     top: _focusNode.offset.dy * 0.5 +
                                    //         painter.height,
                                    //     left: _focusNode.offset.dx * 0.5 +
                                    //         painter.width),
                                    top: _focusNode.offset.dy +
                                        painter.height -
                                        46,
                                    left: _focusNode.offset.dx,

                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...localContacts.map((s) {
                                            displayName = s.displayName ?? '';

                                            if (('@' + s.displayName)
                                                .toLowerCase()
                                                .contains(
                                                    tagText.toLowerCase())) {
                                              return GestureDetector(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.0),
                                                    child: Text(
                                                      displayName,
                                                      style: AppTextStyles
                                                          .regularText14
                                                          .copyWith(
                                                        color: AppColors
                                                            .lightBlue4,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      _onTagSelected(s));
                                            } else {
                                              return SizedBox();
                                            }
                                          }).toList(),
                                          tagList.length == 0
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0),
                                                  child: Text(
                                                    'No matching contacts found.',
                                                    style: AppTextStyles
                                                        .regularText14
                                                        .copyWith(
                                                      color:
                                                          AppColors.lightBlue4,
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightBlue3,
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
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                                color: AppColors.lightBlue4),
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
                                            margin: EdgeInsets.only(right: 30),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  intl.DateFormat(
                                                          'hh:mma | MM.dd.yyyy')
                                                      .format(u.modifiedOn),
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.lightBlue3,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.lightBlue3,
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
                                              style: AppTextStyles
                                                  .regularText16b
                                                  .copyWith(
                                                      color:
                                                          AppColors.lightBlue3),
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
                                                style: AppTextStyles
                                                    .regularText18b
                                                    .copyWith(
                                                        color: AppColors
                                                            .prayeModeBorder),
                                              ),
                                              Text(
                                                intl.DateFormat(' MM.dd.yyyy')
                                                    .format(prayerData
                                                        .prayer.modifiedOn),
                                                style: AppTextStyles
                                                    .regularText18b
                                                    .copyWith(
                                                        color: AppColors
                                                            .prayeModeBorder),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: AppColors.lightBlue3,
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
                                            style: AppTextStyles.regularText16b
                                                .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
