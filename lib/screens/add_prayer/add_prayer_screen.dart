import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import '../entry_screen.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  _AddPrayerState createState() => _AddPrayerState();
}

class _AddPrayerState extends State<AddPrayer> {
  bool _autoValidate = false;
  bool updated;
  bool updateIsValid = false;
  bool hasFocus;
  bool showNoContact = false;
  double numberOfLines = 5.0;
  bool textWithSpace = false;

  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _prayerKey = GlobalKey<FormFieldState>();
  FocusNode _focusNode = FocusNode();

  Iterable<Contact> localContacts = [];
  int fieldIndex;

  List<PrayerUpdateModel> updates;
  List groups = [];
  List<Widget> contactDropDowns;
  List textControllers = [];
  List<String> tagList = [];
  List<Contact> contacts = [];
  List<PrayerTagModel> oldTags = [];
  List<String> tags = [];
  List<String> noTags = [];
  var newDisplayName = '';
  Map<String, TextEditingController> textEditingControllers = {};

  String tagText = '';
  String updateTagText = '';
  String backupText;
  String _oldDescription = '';
  String displayName = '';

  TextPainter painter;

  var displayname = [];
  var textFields = <Stack>[];
  var textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    fieldIndex = null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchMode(false);
      await Provider.of<MiscProvider>(context, listen: false)
          .setSearchQuery('');
      Provider.of<PrayerProvider>(context, listen: false)
          .searchPrayers('', userId);
    });
    super.didChangeDependencies();
  }

  Future<void> _save(textEditingControllers) async {
    BeStilDialog.showLoading(context);
    FocusScope.of(context).unfocus();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    Map<String, dynamic> updatedPrayer = {};
    List<dynamic> prayerUpdateList = [];
    List<PrayerTagModel> textList = [];
    List<PrayerTagModel> updateTextList = [];

    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    try {
      if (_descriptionController.text == null ||
          _descriptionController.text.trim() == '') {
        BeStilDialog.hideLoading(context);
        PlatformException e = PlatformException(
            code: 'custom', message: 'You can not save empty prayers');
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(context, e, user, null);
      } else {
        if (!Provider.of<PrayerProvider>(context, listen: false).isEdit) {
          await Provider.of<PrayerProvider>(context, listen: false).addPrayer(
            _descriptionController.text,
            _user.id,
            '${_user.firstName} ${_user.lastName}',
            backupText,
          );

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
                .addPrayerTag(contacts, _user, _descriptionController.text, '');
          }
          BeStilDialog.hideLoading(context);
          AppCOntroller appCOntroller = Get.find();

          appCOntroller.setCurrentPage(0, true);
        } else {
          var updates = Provider.of<PrayerProvider>(context, listen: false)
              .prayerToEdit
              ?.updates;
          updates.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
          updates =
              updates.where((element) => element.deleteStatus != -1).toList();

          updates.forEach((str) {
            if (textEditingControllers[str.id].text != str.description) {
              updatedPrayer['id'] = str.id;
              updatedPrayer['description'] =
                  textEditingControllers[str.id].text;
              prayerUpdateList = [...prayerUpdateList, updatedPrayer];
            }
          });

          if (prayerUpdateList.length > 0) {
            prayerUpdateList.forEach((element) async {
              if (element['description'] == '') {
                await Provider.of<PrayerProvider>(context, listen: false)
                    .deleteUpdate(element['id']);
              }
              await Provider.of<PrayerProvider>(context, listen: false)
                  .editUpdate(element['description'], element['id']);
            });
          }
          await Provider.of<PrayerProvider>(context, listen: false).editprayer(
              _descriptionController.text,
              Provider.of<PrayerProvider>(context, listen: false)
                  .prayerToEdit
                  .prayer
                  .id);

          //tags
          List<PrayerTagModel> currentTags = [];
          List<PrayerTagModel> initialTags = [];
          final tags = [
            ...Provider.of<PrayerProvider>(context, listen: false)
                .prayerToEdit
                .tags
          ];

          if (updates.length > 0) {
            updates.forEach((x) async {
              if (textEditingControllers[x.id].text != x.description) {
                tags.forEach((tag) async {
                  if (x.description.contains(tag.displayName)) {
                    currentTags = [...currentTags, tag];
                  }
                });
                currentTags.forEach((y) {
                  if (!textEditingControllers[x.id]
                      .text
                      .toLowerCase()
                      .contains(y.displayName.toLowerCase())) {
                    updateTextList.add(y);
                  }
                });
              }
              for (int i = 0; i < updateTextList.length; i++)
                await Provider.of<PrayerProvider>(context, listen: false)
                    .removePrayerTag(updateTextList[i].id);

              if (contacts.length > 0) {
                await Provider.of<PrayerProvider>(context, listen: false)
                    .addPrayerTag(
                        contacts, _user, textEditingControllers[x.id].text, '');
              }
            });
          }

          if (_descriptionController.text !=
              Provider.of<PrayerProvider>(context, listen: false)
                  .prayerToEdit
                  .prayer
                  .description) {
            if (updates.length > 0) {
              tags.forEach((tag) async {
                if (_oldDescription.contains(tag.displayName)) {
                  initialTags = [...initialTags, tag];
                }
              });
              initialTags.forEach((y) {
                if (!_descriptionController.text
                    .toLowerCase()
                    .contains(y.displayName.toLowerCase())) {
                  textList.add(y);
                }
              });
            } else {
              tags.forEach((tag) {
                if (!_descriptionController.text
                    .toLowerCase()
                    .contains(tag.displayName.toLowerCase())) {
                  textList.add(tag);
                }
              });
            }

            for (int i = 0; i < textList.length; i++)
              await Provider.of<PrayerProvider>(context, listen: false)
                  .removePrayerTag(textList[i].id);
            if (contacts.length > 0) {
              await Provider.of<PrayerProvider>(context, listen: false)
                  .addPrayerTag(
                      contacts, _user, _descriptionController.text, '');
            }
          }

          BeStilDialog.hideLoading(context);
          AppCOntroller appCOntroller = Get.find();

          appCOntroller.setCurrentPage(0, true);
        }
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  void initState() {
    final isEdit = Provider.of<PrayerProvider>(context, listen: false).isEdit;
    _descriptionController.text = isEdit
        ? Provider.of<PrayerProvider>(context, listen: false)
            .prayerToEdit
            .prayer
            .description
        : '';

    if (isEdit &&
        Provider.of<PrayerProvider>(context, listen: false).prayerToEdit !=
            null) {
      updates = Provider.of<PrayerProvider>(context, listen: false)
          .prayerToEdit
          ?.updates;
      updates.sort((a, b) => b.modifiedOn.compareTo(a.modifiedOn));
      updates = updates.where((element) => element.deleteStatus != -1).toList();
      updates.forEach(
        (element) {
          textEditingController =
              new TextEditingController(text: element.description);
          textEditingControllers.putIfAbsent(
              element.id, () => textEditingController);
          textControllers.add(textEditingController);
        },
      );
    }

    _oldDescription = _descriptionController.text;
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    var status = await Permission.contacts.status;
    setState(() =>
        Settings.enabledContactPermission = status == PermissionStatus.granted);

    if (Settings.enabledContactPermission) {
      final _localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      localContacts = _localContacts.where((e) => e.displayName != null);
    }
  }

  void _onTextChange(String val) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;

    try {
      var cursorPos = _descriptionController.selection.base.offset;
      var stringBeforeCursor = val.substring(0, cursorPos);
      tags = stringBeforeCursor.split(new RegExp(r"\s"));
      tagText = tags.last.startsWith('@') ? tags.last : '';
      tagList.clear();
      localContacts.forEach((s) {
        var displayName = s.displayName == null ? '' : s.displayName;
        var displayNameList =
            displayName.toLowerCase().split(new RegExp(r"\s"));
        displayNameList.forEach((e) {
          if (('@' + e).toLowerCase().contains(tagText.toLowerCase())) {
            tagList.add(displayName);
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
    } catch (e) {
      print(e);
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), userId, 'ADD_PRAYER/screen/onTextChange_tag');
    }
  }

  void _onUpdateTextChange(String val, TextEditingController controller) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;

    try {
      var cursorPos = controller.selection.base.offset;
      var stringBeforeCursor = val.substring(0, cursorPos);
      tags = stringBeforeCursor.split(new RegExp(r"\s"));
      updateTagText = tags.last.startsWith('@') ? tags.last : '';

      tagList.clear();
      localContacts.forEach((s) {
        var displayName = s.displayName == null ? '' : s.displayName;
        var displayNameList =
            displayName.toLowerCase().split(new RegExp(r"\s"));
        displayNameList.forEach((e) {
          if (('@' + e).toLowerCase().contains(updateTagText.toLowerCase())) {
            tagList.add(displayName);
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
    } catch (e) {
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), userId, 'ADD_PRAYER/screen/onTextChange_tag');
    }
  }

  Future<bool> _onWillPop() async {
    if ((!Provider.of<PrayerProvider>(context, listen: false).isEdit &&
            _descriptionController.text.isNotEmpty) ||
        (Provider.of<PrayerProvider>(context, listen: false).isEdit &&
            _oldDescription != _descriptionController.text)) {
      onCancel();
      return true;
    } else {
      AppCOntroller appCOntroller = Get.find();

      appCOntroller.setCurrentPage(0, true);
      return (Navigator.of(context).pushNamedAndRemoveUntil(
              EntryScreen.routeName, (Route<dynamic> route) => false)) ??
          false;
    }
  }

  Future<void> _onUpdateTagSelected(s, TextEditingController controller) async {
    controller.text =
        controller.text.replaceFirst(updateTagText, s.displayName);

    updateTagText = '';

    setState(() {
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
    });

    if (!contacts.map((e) => e.identifier).contains(s.identifier)) {
      contacts = [...contacts, s];
    }
  }

  Future<void> _onTagSelected(s, TextEditingController controller) async {
    // print(controller.text.replaceFirst(tagText, s.displayName));
    // String controllerText;
    // String tmpText = s.displayName.substring(0, s.displayName.length);

    controller.text = controller.text.replaceFirst(tagText, s.displayName);
    tagText = '';
    updateTagText = '';
    // var tmpTextAfter = controller.text
    //     .substring(controller.text.indexOf('@'), controller.text.length);
    // var textAfter = tmpTextAfter.split(" ");
    // var newText = textAfter..removeAt(0);
    // var joinText = newText.join(" ");

    // controllerText = controller.text.substring(
    //   0,
    //   controller.text.indexOf('@'),
    // );
    // controllerText += tmpText;
    // if (textWithSpace) {
    //   controller.text = controllerText;
    //   textWithSpace = false;
    // } else {
    //   textWithSpace = false;
    // }
    // controller.text = controllerText;
    // controller.text = controllerText + " " + joinText;

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
                      if (Provider.of<PrayerProvider>(context, listen: false)
                          .isEdit) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            EntryScreen.routeName,
                            (Route<dynamic> route) => false);
                      } else {
                        AppCOntroller appCOntroller = Get.find();

                        appCOntroller.setCurrentPage(0, true);
                        Navigator.pop(context);
                        FocusManager.instance.primaryFocus.unfocus();
                      }
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

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
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

    Widget updateContactDropdown(context, e) {
      return Positioned(
        top: ((numberOfLines * positionOffset) * positionOffset2) +
            (textEditingControllers[e.id].selection.baseOffset / 1.8),
        left: 10,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Container(
          padding: EdgeInsets.all(20),
          color: AppColors.prayerCardBgColor,
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
                        .contains(updateTagText.toLowerCase().substring(1))) {
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
                        onTap: () => _onUpdateTagSelected(
                            s, textEditingControllers[e.id]));
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

    Widget contactDropdown(context) {
      return Positioned(
        top: ((numberOfLines * positionOffset) * positionOffset2) +
            (_descriptionController.selection.baseOffset / 1.8),
        left: 10,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Container(
          padding: EdgeInsets.all(20),
          color: AppColors.prayerCardBgColor,
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

    bool isValid =
        (!Provider.of<PrayerProvider>(context, listen: false).isEdit &&
                _descriptionController.text.trim().isNotEmpty) ||
            (Provider.of<PrayerProvider>(context, listen: false).isEdit &&
                _oldDescription.trim() != _descriptionController.text.trim() &&
                _descriptionController.text.trim().isNotEmpty) ||
            (Provider.of<PrayerProvider>(context, listen: false).isEdit &&
                updates.length > 0 &&
                _descriptionController.text.trim().isNotEmpty);

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
                            onTap: isValid
                                ? () => onCancel()
                                : Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .isEdit
                                    ? () {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        Navigator.pop(context);
                                      }
                                    : () {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        AppCOntroller appCOntroller =
                                            Get.find();

                                        appCOntroller.setCurrentPage(0, true);
                                      },
                          ),
                          InkWell(
                            child: Text('SAVE',
                                style: AppTextStyles.boldText18.copyWith(
                                    color: !isValid
                                        ? AppColors.lightBlue5.withOpacity(0.5)
                                        : Colors.blue)),
                            onTap: () =>
                                isValid ? _save(textEditingControllers) : null,
                          ),
                        ])),
                Expanded(
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: fieldIndex = null,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Form(
                                  // ignore: deprecated_member_use
                                  autovalidate: _autoValidate,
                                  key: _formKey,
                                  child: Container(
                                    child: CustomInput(
                                      textkey: _prayerKey,
                                      label: 'Prayer description',
                                      controller: _descriptionController,
                                      maxLines: Provider.of<PrayerProvider>(
                                                      context,
                                                      listen: false)
                                                  .isEdit &&
                                              updates.length > 0 &&
                                              tagText.length == 0
                                          ? 10
                                          : 30,
                                      isRequired: true,
                                      showSuffix: false,
                                      textInputAction: TextInputAction.newline,
                                      onTextchanged: (val) =>
                                          _onTextChange(val),
                                      focusNode:
                                          !updateIsValid ? _focusNode : null,
                                    ),
                                  ),
                                ),
                              ),
                              tagText.length > 1 &&
                                      Settings.enabledContactPermission &&
                                      Provider.of<PrayerProvider>(context,
                                                  listen: false)
                                              .prayerToEdit
                                              ?.prayer
                                              ?.description !=
                                          _descriptionController.text
                                  ? contactDropdown(context)
                                  : SizedBox(),
                            ],
                          ),
                          if (Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .prayerToEdit !=
                                  null &&
                              updates.length > 0)
                            ...updates.map(
                              (e) => Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Container(
                                      child: TextFormField(
                                        controller:
                                            textEditingControllers[e.id],
                                        textInputAction:
                                            TextInputAction.newline,
                                        maxLines:
                                            updateTagText.length == 0 ? 10 : 23,
                                        keyboardType: TextInputType.multiline,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        style: AppTextStyles.regularText15,
                                        cursorColor: AppColors.lightBlue4,
                                        onChanged: (val) {
                                          // setState(() {});
                                          _onUpdateTextChange(val,
                                              textEditingControllers[e.id]);
                                          // if (e.description.trim() !=
                                          //     textEditingController.text
                                          //         .trim()) {
                                          //   updateIsValid = true;
                                          // } else {
                                          //   updateIsValid = false;
                                          // }
                                          // });
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
                                  ),
                                  updateTagText.length > 1 &&
                                          Settings.enabledContactPermission &&
                                          updates[updates.indexOf(e)]
                                                  .description !=
                                              textEditingControllers[e.id].text
                                      ? updateContactDropdown(context, e)
                                      : SizedBox(),
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
