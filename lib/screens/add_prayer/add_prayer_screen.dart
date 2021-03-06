import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/save_options.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  _AddPrayerState createState() => _AddPrayerState();
}

class Backup {
  String id;
  String backupText;
  List<Contact> contactList;
  bool showContactDropDown;
  TextEditingController ctrl;
  FocusNode focusNode;
  GlobalKey widgetKey;
  Backup(this.id, this.backupText, this.ctrl, this.showContactDropDown,
      this.contactList, this.focusNode, this.widgetKey);
}

class _AddPrayerState extends State<AddPrayer> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double numberOfLines = 5.0;
  bool showContactList = false;
  bool showDropdown = false;
  bool getContactCalled = false;
  bool deniedTapped = false;

  List<UpdateModel> updates = [];
  List<Backup> updateTextControllers = [];
  List<Contact> localContacts = [];
  String _backupDescription = '';
  FocusNode _focusNode = FocusNode();
  bool _isInit = true;
  List<Contact> tagList = [];
  List<Contact> contactList = [];
  List<Contact> updateContactList = [];
  List<SaveOption> saveOptions = [];
  String tagText = '';
  SaveOption? selected;
  final widgetKey = GlobalKey();

  showContactConsentModal() {
    BeStilDialog.showContactAccessDialog(context,
        onConfirm: () => confirmContactConsent(),
        onCancel: () => denyContactConsent(),
        title: 'Contacts',
        message:
            'With your permission, Be Still will access your contacts information so you can easily send emails and texts while reading the contents of prayers.  If you choose to use this feature, Be Still will ask for permission to access your contacts information the first time you use it.',
        confirmText: 'OK',
        cancelText: 'Not Now');
  }

  confirmContactConsent() {
    deniedTapped = false;
    _getContactPermission();
  }

  denyContactConsent() {
    deniedTapped = true;
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          var userId = FirebaseAuth.instance.currentUser?.uid;
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
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _edit(UserDataModel _user) async {
    final userName = (_user.firstName ?? '') + ' ' + (_user.lastName ?? '');

    PrayerDataModel prayerToEdit =
        Provider.of<PrayerProviderV2>(context, listen: false).prayerToEdit;
    final prayerId = prayerToEdit.id ?? '';

    if (updateTextControllers.length > 0) {
      updateTextControllers.forEach((update) async {
        if (update.ctrl.text.isEmpty) {
          await Provider.of<PrayerProviderV2>(context, listen: false)
              .deleteUpdate(
                  prayerToEdit.id ?? '',
                  (prayerToEdit.updates ?? <UpdateModel>[])
                      .firstWhere((element) => element.id == update.id));
        } else {
          final updateValue =
              (prayerToEdit.updates ?? <UpdateModel>[]).firstWhere(
            (element) => element.id == update.id,
            orElse: () => UpdateModel(),
          );

          if (update.ctrl.text != updateValue.description) {
            await Provider.of<PrayerProviderV2>(context, listen: false)
                .editUpdate(
              update.ctrl.text,
              prayerToEdit.id ?? '',
              updateValue,
            );
          }
        }
      });
    }
    if (_descriptionController.text != prayerToEdit.description) {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .editprayer(_descriptionController.text, prayerId);
    }

    contactListCheck();

    //tags
    final tags = [
      ...Provider.of<PrayerProviderV2>(context, listen: false).prayerToEditTags
    ];
    final List<String> ids = [];
    if (updates.length > 0) {
      for (final up in updateTextControllers) {
        if (up.backupText != up.ctrl.text) {
          for (final c in up.contactList) {
            if (!tags.any((t) => t.contactIdentifier == c.identifier)) {
              await Provider.of<PrayerProviderV2>(context, listen: false)
                  .addPrayerTag(
                      updateContactList, userName, up.ctrl.text, prayerId);
              ids.add(up.ctrl.text);
            }
          }
        }
      }
    }

    if (_backupDescription != _descriptionController.text) {
      if (tags.any((tag) =>
          _descriptionController.text.contains(tag.displayName ?? ''))) {}

      for (final c in contactList) {
        if (!tags.any((t) => t.contactIdentifier == c.identifier)) {
          await Provider.of<PrayerProviderV2>(context, listen: false)
              .addPrayerTag(
            contactList,
            userName,
            _descriptionController.text,
            prayerId,
          );
          ids.add(_descriptionController.text);
        }
      }
    }

    var prayerTags = <TagModel>[];
    var tagsToRemove = <TagModel>[];

    for (final tag in tags) {
      if ((_descriptionController.text
          .contains(((tag.displayName ?? '') + ' ')))) {
        prayerTags.add(tag);
      }
      updateTextControllers.forEach((element) async {
        if (updateTextControllers.isNotEmpty) {
          updateTextControllers.forEach((element) {
            if (element.ctrl.text.contains((tag.displayName ?? '') + ' ')) {
              prayerTags.add(tag);
            }
          });
        }
      });
      tagsToRemove = tags.toSet().difference(prayerTags.toSet()).toList();
    }
    tagsToRemove.forEach((tag) async {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .removePrayerTag(tag, prayerId);
    });

    BeStilDialog.hideLoading(context);
    AppController appController = Get.find();

    if (appController.previousPage == 0 || appController.previousPage == 7) {
      appController.setCurrentPage(0, true, 1);
    } else {
      final groupId =
          (Provider.of<GroupProviderV2>(context, listen: false).currentGroup)
                  .id ??
              '';

      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(groupId);
      appController.setCurrentPage(8, true, 1);
    }
  }

  Future<void> _save() async {
    BeStilDialog.showLoading(context);

    try {
      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      AppController appController = Get.find();

      setState(() => _autoValidate = true);
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
      if (_descriptionController.text.trim().isEmpty) {
        BeStilDialog.hideLoading(context);
        PlatformException e = PlatformException(
            code: 'custom', message: 'You can not save empty prayers');
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        final s = StackTrace.fromString(e.stacktrace ?? '');
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      } else {
        if (!Provider.of<PrayerProviderV2>(context, listen: false).isEdit) {
          if ((selected?.name ?? '').isEmpty ||
              (selected?.name) == 'My Prayers') {
            contactListCheck();
            await Provider.of<PrayerProviderV2>(context, listen: false)
                .addPrayer('', _descriptionController.text, false, contactList);
            BeStilDialog.hideLoading(context);
            appController.setCurrentPage(0, true, 1);
          } else {
            contactListCheck();
            await Provider.of<PrayerProviderV2>(context, listen: false)
                .addPrayer((selected?.id ?? ''), _descriptionController.text,
                    true, contactList);
            await Provider.of<GroupProviderV2>(context, listen: false)
                .setCurrentGroupById(selected?.id ?? '');
            BeStilDialog.hideLoading(context);
            appController.setCurrentPage(8, true, 1);
          }
        } else {
          _edit(_user);
        }
      }
    } on HttpException catch (e, s) {
      showError(e, s);
    } catch (e, s) {
      showError(e, s);
    }
  }

  void showError(e, s) {
    BeStilDialog.hideLoading(context);
    final user =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    BeStilDialog.showErrorDialog(
        context, StringUtils.getErrorMessage(e), user, s);
  }

  void contactListCheck() {
    var tagsToKeep = <Contact>[];
    var updateTagsToKeep = <Contact>[];
    var tagsToRemove = <Contact>[];
    var updateTagsToRemove = <Contact>[];
    if (contactList.isNotEmpty)
      contactList.forEach((element) {
        if ((_descriptionController.text
            .contains((element.displayName ?? '') + ' '))) {
          tagsToKeep.add(element);
        }
      });

    if (updateContactList.isNotEmpty) {
      updateContactList.forEach((t) {
        updateTextControllers.forEach((e) async {
          if (e.ctrl.text.contains((t.displayName ?? '') + ' ')) {
            updateTagsToKeep.add(t);
          }
        });
      });
    }

    tagsToRemove = contactList.toSet().difference(tagsToKeep.toSet()).toList();
    updateTagsToRemove =
        updateContactList.toSet().difference(updateTagsToKeep.toSet()).toList();

    tagsToRemove.forEach((element) {
      contactList.removeWhere((e) => e == element);
    });
    updateTagsToRemove.forEach((element) {
      updateContactList.removeWhere((e) => e == element);
    });
  }

  @override
  void initState() {
    super.initState();

    final isEdit = Provider.of<PrayerProviderV2>(context, listen: false).isEdit;
    _descriptionController.text = isEdit
        ? (Provider.of<PrayerProviderV2>(context, listen: false).prayerToEdit)
                .description ??
            ''
        : '';

    _backupDescription = _descriptionController.text;

    if (isEdit) {
      showDropdown = false;

      updates = Provider.of<PrayerProviderV2>(context, listen: false)
          .prayerToEditUpdate;
      updates.sort((a, b) => (b.modifiedDate ?? DateTime.now())
          .compareTo(a.modifiedDate ?? DateTime.now()));
      updates =
          updates.where((element) => element.status != Status.deleted).toList();

      updateTextControllers = updates
          .map((e) => Backup(
              e.id ?? '',
              e.description ?? '',
              TextEditingController()..text = e.description ?? '',
              false,
              [],
              FocusNode(),
              GlobalKey()))
          .toList();
    } else {
      showDropdown =
          Provider.of<PrayerProviderV2>(context, listen: false).showDropDown;
    }
    final userGroups =
        Provider.of<GroupProviderV2>(context, listen: false).userGroups;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    saveOptions.add(SaveOption(id: userId, name: 'My Prayers'));
    if (userGroups.length > 0) {
      for (final element in userGroups) {
        final option =
            new SaveOption(id: element.id ?? '', name: element.name ?? '');
        saveOptions.add(option);
      }
    }
    AppController appController = Get.find();
    if (appController.previousPage == 0 || appController.previousPage == 7) {
      selected = saveOptions[0];
    } else {
      final group =
          Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
      saveOptions.forEach((element) {
        if (element.id == (group.id ?? '')) {
          selected = element;
        }
      });
    }
  }

  Future<void> getContacts() async {
    var status = await Permission.contacts.status;

    Settings.enabledContactPermission = status == PermissionStatus.granted;

    if (Settings.enabledContactPermission) {
      final _localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      localContacts =
          _localContacts.where((e) => e.displayName != null).toList();
    }
    getContactCalled = true;
    setState(() => {});
  }

  void _getContactPermission() async {
    try {
      await Permission.contacts.request().then((p) {
        if (p == PermissionStatus.granted) {
          Settings.enabledContactPermission = true;
        } else {
          Settings.enabledContactPermission = false;
          deniedTapped = true;
        }
        return Settings.enabledContactPermission =
            p == PermissionStatus.granted;
      });
      getContacts();
    } catch (e) {
      // BeStilDialog.showErrorDialog(
      //     context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    }
  }

  Future<void> _onTextChange(String val, {Backup? backup}) async {
    try {
      var platform = Theme.of(context).platform;

      if (tagText.length > 0 &&
          Settings.enabledContactPermission == false &&
          !deniedTapped &&
          !Provider.of<PrayerProviderV2>(context, listen: false).isEdit) {
        if (platform == TargetPlatform.android) {
          showContactConsentModal();
        } else {
          _getContactPermission();
        }
      } else {
        if (getContactCalled == false &&
            Settings.enabledContactPermission == true) {
          getContacts();
        }
        final cursorPos =
            (backup == null ? _descriptionController : backup.ctrl)
                .selection
                .base
                .offset;
        final stringBeforeCursor = val.substring(0, cursorPos);
        final tags = stringBeforeCursor.split(new RegExp(r"\s"));
        tagText = tags.last.startsWith('@') ? tags.last : '';
        setContactList(tagText);

        if (tagText.length > 1) {
          if (backup == null)
            showContactList = true;
          else
            backup.showContactDropDown = true;
          setLineCount(val);
        } else {
          showContactList = false;
          updateTextControllers = updateTextControllers
              .map((e) => e..showContactDropDown = false)
              .toList();
        }
      }

      setState(() {});
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  setContactList(String tagText) {
    tagList.clear();
    tagList = localContacts
        .where((c) => ('@' + (c.displayName ?? ''))
            .toLowerCase()
            .contains(tagText.toLowerCase()))
        .toList();
  }

  setLineCount(String val) async {
    TextPainter painter = TextPainter(
        textDirection: TextDirection.ltr, text: TextSpan(text: val));

    painter.layout();

    RenderBox box = widgetKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    double y = position.dy;
    numberOfLines = (_focusNode.offset.dy + painter.height + 3) - y;
  }

  Future<bool> _onWillPop() async {
    bool isValid = (!Provider.of<PrayerProviderV2>(context).isEdit &&
            _descriptionController.text.trim().isNotEmpty) ||
        (Provider.of<PrayerProviderV2>(context).isEdit &&
            _backupDescription.trim() != _descriptionController.text.trim());

    bool isUpdateValid = Provider.of<PrayerProviderV2>(context).isEdit &&
        updateTextControllers
            .any((e) => e.backupText.trim() != e.ctrl.text.trim());
    if (updates.length > 0) isValid = isValid || isUpdateValid;
    if (!isValid) {
      onCancel();
      return true;
    } else {
      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 1);
      return false;
    }
  }

  Widget contactDropdown({Backup? backup}) {
    return Positioned(
      top: numberOfLines + 10,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 300,
        decoration: BoxDecoration(
            color: AppColors.backgroundColor[0],
            border: Border(
                top: BorderSide(color: AppColors.lightBlue3, width: 0.5))),
        width: Get.width - 80,
        child: tagList.length == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'No matchings contacts found.',
                    style: AppTextStyles.regularText14.copyWith(
                      color: AppColors.lightBlue4,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...tagList.map((s) {
                      final displayName = s.displayName;
                      if ((displayName ?? '').isNotEmpty) {
                        return GestureDetector(
                            child: Row(
                              children: [
                                Container(
                                  width: Get.width - 100,
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(
                                    displayName ?? '',
                                    style: AppTextStyles.regularText14.copyWith(
                                      color: AppColors.lightBlue4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _onTagSelected(s, backup));
                      } else {
                        return SizedBox();
                      }
                    }).toList(),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _onTagSelected(Contact s, Backup? backup) async {
    if (!(backup == null ? contactList : backup.contactList)
        .any((e) => e.identifier == s.identifier)) {
      if (backup == null) {
        contactList = [...contactList, s];
      } else {
        backup.contactList = [...backup.contactList, s];
        backup.contactList.forEach((element) {
          updateContactList.add(element);
        });
      }
    }
    (backup == null ? _descriptionController : backup.ctrl).text =
        (backup == null ? _descriptionController : backup.ctrl)
            .text
            .replaceFirst(tagText, (s.displayName ?? '') + ' ');
    setState(() {
      if (backup == null) {
        showContactList = false;
      } else {
        updateTextControllers = updateTextControllers
            .map((e) => e..showContactDropDown = false)
            .toList();
      }
      (backup == null ? _descriptionController : backup.ctrl).selection =
          TextSelection.collapsed(
              offset: (backup == null ? _descriptionController : backup.ctrl)
                  .text
                  .length);
    });
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
                        try {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          AppController appController = Get.find();
                          appController.setCurrentPage(
                              appController.previousPage, true, 1);
                          Navigator.pop(context);
                        } on HttpException catch (e, s) {
                          final user = Provider.of<UserProviderV2>(context,
                                  listen: false)
                              .currentUser;
                          BeStilDialog.showErrorDialog(
                              context, StringUtils.getErrorMessage(e), user, s);
                        } catch (e, s) {
                          final user = Provider.of<UserProviderV2>(context,
                                  listen: false)
                              .currentUser;
                          BeStilDialog.showErrorDialog(
                              context, StringUtils.getErrorMessage(e), user, s);
                        }
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
                        // width: MediaQuery.of(context).size.width * .30,
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

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<void> _onGroupPrayerSave() async {
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
        // height: MediaQuery.of(context).size.height * 0.33,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'Add Prayer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'You are about to add a new prayer to ${selected?.name ?? ''}, where it can be seen by other members of the group.',
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
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
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
                      onTap: () {
                        // FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.pop(context);

                        _save();
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        // width: MediaQuery.of(context).size.width * .30,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
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

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    final userGroups = Provider.of<GroupProviderV2>(context).userGroups;
    bool canSave =
        _backupDescription.trim() == _descriptionController.text.trim()
            ? false
            : _descriptionController.text.trim().isNotEmpty;

    bool isUpdateValid = Provider.of<PrayerProviderV2>(context).isEdit &&
        updateTextControllers
            .any((e) => e.backupText.trim() != e.ctrl.text.trim());
    if (updates.length > 0) canSave = canSave || isUpdateValid;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.backgroundColor)),
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
                              onTap: canSave
                                  ? () => onCancel()
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      AppController appController = Get.find();

                                      appController.setCurrentPage(
                                          appController.previousPage, true, 1);
                                    }),
                          InkWell(
                              child: Text('SAVE',
                                  style: AppTextStyles.boldText18.copyWith(
                                      color: !canSave
                                          ? AppColors.lightBlue5
                                              .withOpacity(0.5)
                                          : Colors.blue)),
                              onTap: () {
                                FocusScope.of(context).unfocus();

                                if (canSave) {
                                  if ((selected?.name ?? '').isEmpty ||
                                      (selected?.name) == 'My Prayers') {
                                    _save();
                                  } else {
                                    if (!Provider.of<PrayerProviderV2>(context,
                                            listen: false)
                                        .isEdit) {
                                      _onGroupPrayerSave();
                                    } else {
                                      _save();
                                    }
                                  }
                                }
                              }),
                        ])),
                showDropdown && userGroups.length > 0
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60.0,
                        padding: EdgeInsets.only(top: 10),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 20),
                          decoration: BoxDecoration(
                              color: AppColors.textFieldBackgroundColor,
                              border: Border.all(
                                  color: AppColors.lightBlue4.withOpacity(0.5)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: new DropdownButton<SaveOption>(
                                  hint: Container(
                                    margin: const EdgeInsets.only(
                                        left: 5.0, right: 10),
                                    child: new Text('Save prayer to?',
                                        style: new TextStyle(
                                            color: AppColors.lightBlue4)),
                                  ),
                                  iconEnabledColor: AppColors.lightBlue4,
                                  iconDisabledColor: AppColors.grey,
                                  isExpanded: true,
                                  dropdownColor:
                                      AppColors.textFieldBackgroundColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  value: selected,
                                  isDense: false,
                                  onChanged: (value) {
                                    setState(() {
                                      selected = value ??
                                          SaveOption(
                                              id: '', name: 'My Prayers');
                                    });
                                  },
                                  items: saveOptions.map((SaveOption e) {
                                    return new DropdownMenuItem<SaveOption>(
                                      value: e,
                                      child: new Text(
                                        e.name ?? '',
                                        style: new TextStyle(
                                            color: AppColors.lightBlue4),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: null, //() => fieldIndex = null,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                key: widgetKey,
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Form(
                                  autovalidateMode: _autoValidate
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.disabled,
                                  key: _formKey,
                                  child: Container(
                                    child: CustomInput(
                                      focusNode: _focusNode,

                                      // textkey: _prayerKey,
                                      label: 'Prayer description',
                                      controller: _descriptionController,
                                      maxLines: Provider.of<PrayerProviderV2>(
                                                      context,
                                                      listen: false)
                                                  .isEdit &&
                                              updates.length > 0
                                          ? 10
                                          : 30,
                                      isRequired: true,
                                      showSuffix: false,
                                      textInputAction: TextInputAction.newline,
                                      onTextchanged: (val) =>
                                          _onTextChange(val),
                                    ),
                                  ),
                                ),
                              ),
                              if (showContactList &&
                                  Settings.enabledContactPermission)
                                contactDropdown()
                            ],
                          ),
                          if (((Provider.of<PrayerProviderV2>(context,
                                                  listen: false)
                                              .prayerToEdit)
                                          .id ??
                                      '')
                                  .isNotEmpty &&
                              updates.length > 0)
                            ...updates.map(
                              (e) => Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Stack(
                                  children: [
                                    Container(
                                      key: updateTextControllers[
                                              updates.indexOf(e)]
                                          .widgetKey,
                                      child: TextFormField(
                                        controller: updateTextControllers[
                                                updates.indexOf(e)]
                                            .ctrl,
                                        focusNode: updateTextControllers[
                                                updates.indexOf(e)]
                                            .focusNode,
                                        textInputAction:
                                            TextInputAction.newline,
                                        maxLines: 10,
                                        keyboardType: TextInputType.multiline,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        style: AppTextStyles.regularText15,
                                        cursorColor: AppColors.lightBlue4,
                                        onChanged: (val) {
                                          _onTextChange(val,
                                              backup: updateTextControllers[
                                                  updates.indexOf(e)]);
                                        },
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0, vertical: 20.0),
                                          suffixStyle: AppTextStyles
                                              .regularText14
                                              .copyWith(
                                                  color: Settings.isDarkMode
                                                      ? AppColors.offWhite2
                                                      : AppColors
                                                          .prayerTextColor),
                                          counterText: '',
                                          hintText: 'Prayer update description',
                                          hintStyle: AppTextStyles.regularText15
                                              .copyWith(height: 1.5),
                                          errorBorder: new OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.redAccent),
                                          ),
                                          errorMaxLines: 5,
                                          errorStyle: AppTextStyles.errorText,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.lightBlue4
                                                  .withOpacity(0.5),
                                              width: 1.0,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.lightBlue4,
                                                width: 1.0),
                                          ),
                                          fillColor: AppColors
                                              .textFieldBackgroundColor,
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                    if (updateTextControllers[
                                                updates.indexOf(e)]
                                            .showContactDropDown &&
                                        Settings.enabledContactPermission)
                                      contactDropdown(
                                          backup: updateTextControllers[
                                              updates.indexOf(e)])
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ).marginOnly(bottom: updates.length > 0 ? 100 : 0),
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
