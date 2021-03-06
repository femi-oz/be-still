import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/user.model.dart';

import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

class AddUpdate extends StatefulWidget {
  static const routeName = 'update-prayer';
  @override
  _AddUpdateState createState() => _AddUpdateState();
}

class _AddUpdateState extends State<AddUpdate> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();
  bool _autoValidate = false;
  final _prayerKey = GlobalKey();
  bool textWithSpace = false;
  bool getContactCalled = false;

  List<String> tags = [];
  String tagText = '';
  List<Contact> contacts = [];
  List<TagModel> oldTags = [];
  String backupText = '';
  TextPainter painter = TextPainter();
  bool showNoContact = false;
  String displayName = '';
  List<String> tagList = [];
  double numberOfLines = 5.0;
  PermissionStatus status = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
  }

  bool isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          var userId = Provider.of<UserProviderV2>(context, listen: false)
              .currentUser
              .id;
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setSearchMode(false);
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setSearchQuery('');
          Provider.of<PrayerProviderV2>(context, listen: false)
              .searchPrayers('', userId ?? '');
        } on HttpException catch (e, s) {
          final user =
              Provider.of<UserProviderV2>(context, listen: false).currentUser;
          BeStilDialog.showErrorDialog(
              context, StringUtils.getErrorMessage(e), user, s);
        } catch (e, s) {
          final user =
              Provider.of<UserProviderV2>(context, listen: false).currentUser;
          BeStilDialog.showErrorDialog(
              context, StringUtils.getErrorMessage(e), user, s);
        }
      });
      isInit = false;
    }
    super.didChangeDependencies();
  }

  showContactConsentModal() {
    BeStilDialog.showContactAccessDialog(context,
        onConfirm: () => confirmContactConsent(),
        onCancel: () => denyContactConsent(),
        title: 'Contacts',
        message:
            'Bestill collects contact data in order to enable the tag feature. This allows Bestill to send email or text messages to your tagged contacts.',
        confirmText: 'OK',
        cancelText: 'Not Now');
  }

  confirmContactConsent() async {
    status = PermissionStatus.granted;
    _getContactPermission();
  }

  denyContactConsent() {
    status = PermissionStatus.denied;
  }

  Future<void> getContacts() async {
    if (Settings.enabledContactPermission) {
      final _localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      localContacts = _localContacts.where((e) => e.displayName != null);
      getContactCalled = true;
    }
  }

  void _getContactPermission() async {
    try {
      await Permission.contacts.request().then((p) =>
          Settings.enabledContactPermission = p == PermissionStatus.granted);
      getContacts();
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    }
  }

  Future<void> _onTextChange(String val) async {
    try {
      final cursorPos = _descriptionController.selection.base.offset;
      var stringBeforeCursor = val.substring(0, cursorPos);
      tags = stringBeforeCursor.split(new RegExp(r"\s"));
      tagText = tags.last.startsWith('@') ? tags.last : '';
      tagList.clear();

      if (getContactCalled == false &&
          Settings.enabledContactPermission == true) {
        getContacts();
      }
      localContacts.forEach((s) {
        var displayName = s.displayName == null ? '' : s.displayName;
        var displayNameList =
            (displayName ?? '').toLowerCase().split(new RegExp(r"\s"));
        displayNameList.forEach((e) {
          if (('@' + e).toLowerCase().contains(tagText.toLowerCase())) {
            tagList.add(displayName ?? '');
          }
        });
      });

      painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: val,
        ),
      );

      painter.layout();
      var lines = painter.computeLineMetrics();
      setState(() {
        numberOfLines = lines.length.toDouble();
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  Future<void> _onTagSelected(
      Contact s, TextEditingController controller) async {
    controller.text =
        controller.text.replaceFirst(tagText, (s.displayName ?? '') + ' ');
    tagText = '';
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    setState(() {
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
    });
    if (!contacts.map((e) => e.identifier).contains(s.identifier)) {
      contacts = [...contacts, s];
    }
  }

  Future<void> _save(String prayerId) async {
    setState(() => _autoValidate = true);

    final updates = Provider.of<PrayerProviderV2>(context, listen: false)
        .prayerToEditUpdate;

    try {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
      BeStilDialog.showLoading(context);
      if (_descriptionController.text.trim().isEmpty) {
        BeStilDialog.hideLoading(context);
        PlatformException e = PlatformException(
            code: 'custom', message: 'You can not save empty prayers');
        final s = StackTrace.fromString(e.stacktrace ?? '');
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      } else {
        await Provider.of<PrayerProviderV2>(context, listen: false)
            .addPrayerUpdate(
          updates,
          prayerId,
          _descriptionController.text,
        );

        contactListCheck();
        if (contacts.length > 0) {
          final user =
              Provider.of<UserProviderV2>(context, listen: false).currentUser;
          final userName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
          await Provider.of<PrayerProviderV2>(context, listen: false)
              .addPrayerTag(
                  contacts, userName, _descriptionController.text, prayerId);
        }
        AppController appController = Get.find();

        if (appController.previousPage == 9 ||
            appController.previousPage == 8) {
          final groupId = (Provider.of<GroupProviderV2>(context, listen: false)
                      .currentGroup)
                  .id ??
              '';

          await Provider.of<NotificationProviderV2>(context, listen: false)
              .sendPrayerNotification(
            prayerId,
            NotificationType.prayer_updates,
            groupId,
            _descriptionController.text,
          );
        }

        BeStilDialog.hideLoading(context);
        FocusScope.of(context).requestFocus(new FocusNode());
        appController.setCurrentPage(appController.previousPage, true, 13);
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void contactListCheck() {
    var tagsToKeep = <Contact>[];
    var tagsToRemove = <Contact>[];
    if (contacts.isNotEmpty)
      contacts.forEach((element) {
        if ((_descriptionController.text
            .contains((element.displayName ?? '') + ' '))) {
          tagsToKeep.add(element);
        }
      });

    tagsToRemove = contacts.toSet().difference(tagsToKeep.toSet()).toList();

    tagsToRemove.forEach((element) {
      contacts.removeWhere((e) => e == element);
    });
  }

  Future<bool> _onWillPop() async {
    return false;
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
              margin: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        AppController appController = Get.find();
                        appController.setCurrentPage(
                            appController.previousPage, true, 13);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Discard Changes',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Resume Editing',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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

  Widget contactDropdown(
      context, double positionOffset, double positionOffset2) {
    return Positioned(
      top: ((numberOfLines * positionOffset) * positionOffset2) +
          (_descriptionController.selection.baseOffset / 1.8),
      left: 10,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Container(
        padding: EdgeInsets.all(20),
        color: AppColors.backgroundColor[0],
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...localContacts.map((s) {
                displayName = s.displayName ?? '';
                var name = '';

                var displayNameList =
                    displayName.toLowerCase().split(new RegExp(r"\s"));
                displayNameList.forEach((e) {
                  if (e
                      .toLowerCase()
                      .contains(tagText.toLowerCase().substring(1))) {
                    name = e;
                  }
                });
                if (name.isNotEmpty) {
                  return GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          displayName,
                          style: AppTextStyles.regularText14.copyWith(
                            color: AppColors.lightBlue4,
                          ),
                        ),
                      ),
                      onTap: () => _onTagSelected(s, _descriptionController));
                } else {
                  return SizedBox();
                }
              }).toList(),
              tagList.length == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No matching contacts found.',
                        style: AppTextStyles.regularText14.copyWith(
                          color: AppColors.lightBlue4,
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final prayer = Provider.of<PrayerProviderV2>(context).prayerToEdit;
    final updates = Provider.of<PrayerProviderV2>(context).prayerToEditUpdate;

    var positionOffset = 3.0;
    var positionOffset2 = 0.0;

    if (numberOfLines == 1.0) {
      positionOffset2 = 24;
    } else if (numberOfLines == 2.0) {
      positionOffset2 = 19;
    } else if (numberOfLines == 3.0) {
      positionOffset2 = 14;
    } else if (numberOfLines > 8) {
      positionOffset2 = 7;
    } else {
      positionOffset2 = 9;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
          ),
          padding: EdgeInsets.only(
              bottom: 20,
              left: 20,
              right: 20,
              top: MediaQuery.of(context).padding.top + 20),
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
                        onTap: _descriptionController.text.isNotEmpty
                            ? () => onCancel()
                            : () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                AppController appController = Get.find();
                                appController.setCurrentPage(
                                    appController.previousPage, true, 13);
                              }),
                    InkWell(
                      child: Text('SAVE',
                          style: AppTextStyles.boldText18.copyWith(
                              color: _descriptionController.text.isEmpty
                                  ? AppColors.lightBlue5.withOpacity(0.5)
                                  : Colors.blue)),
                      onTap: () => _descriptionController.text.isNotEmpty
                          ? _save(prayer.id ?? '')
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
                            // ignore: deprecated_member_use
                            // autovalidate: _autoValidate,
                            autovalidateMode: _autoValidate
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            key: _formKey,
                            child: CustomInput(
                              textkey: _prayerKey,
                              label: "Enter your prayer update here",
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
                          tagText.length > 1 &&
                                  Settings.enabledContactPermission
                              ? contactDropdown(
                                  context, positionOffset, positionOffset2)
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
                            prayer.userId != userId
                                ? Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      prayer.creatorName ?? '',
                                      style: AppTextStyles.regularText16b
                                          .copyWith(
                                              color: AppColors.lightBlue4),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Container(),
                            ...updates.map(
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
                                                    .format(u.modifiedDate ??
                                                        DateTime.now()),
                                                style: AppTextStyles
                                                    .regularText18b
                                                    .copyWith(
                                                        color: AppColors
                                                            .prayerModeBorder),
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
                                            u.description ?? '',
                                            style: AppTextStyles.regularText16b
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
                                                          .prayerModeBorder),
                                            ),
                                            Text(
                                              intl.DateFormat(' MM.dd.yyyy')
                                                  .format(prayer.modifiedDate ??
                                                      DateTime.now()),
                                              style: AppTextStyles
                                                  .regularText18b
                                                  .copyWith(
                                                      color: AppColors
                                                          .prayerModeBorder),
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
                                          prayer.description ?? '',
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
    );
  }
}
