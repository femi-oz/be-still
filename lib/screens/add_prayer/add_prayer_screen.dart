import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import '../entry_screen.dart';

class AddPrayer extends StatefulWidget {
  static const routeName = '/app-prayer';

  final bool showCancel;
  final bool isEdit;
  final bool isGroup;
  final CombinePrayerStream prayerData;
  final Function setCurrentIndex;

  @override
  AddPrayer({
    this.isEdit,
    this.prayerData,
    this.isGroup,
    this.showCancel = true,
    this.setCurrentIndex,
  });
  _AddPrayerState createState() => _AddPrayerState();
}

class _AddPrayerState extends State<AddPrayer> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _prayerKey = GlobalKey<FormFieldState>();
  List groups = [];
  Iterable<Contact> localContacts = [];
  FocusNode _focusNode = FocusNode();
  List<String> tags = [];
  String tagText = '';
  List<Contact> contacts = [];
  List<PrayerTagModel> oldTags = [];
  bool _autoValidate = false;
  String backupText;
  String _oldDescription = '';
  TextPainter painter;
  bool showNoContact = false;
  String displayName = '';
  List<String> tagList = [];
  var displayname = [];
  double numberOfLines = 5.0;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    BeStilDialog.showLoading(context);
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

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
        if (!widget.isEdit) {
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
          widget.setCurrentIndex(0, true);
        } else {
          await Provider.of<PrayerProvider>(context, listen: false).editprayer(
              _descriptionController.text, widget.prayerData.prayer.id);
          List<PrayerTagModel> textList = [];
          final text = [...widget.prayerData.tags];
          text.forEach((element) {
            if (widget.prayerData.updates.length == 0) {
              if (!_descriptionController.text
                  .toLowerCase()
                  .contains(element.displayName.toLowerCase())) {
                textList.add(element);
              }
            } else {
              widget.prayerData.updates.forEach((update) {
                if (!_descriptionController.text
                        .toLowerCase()
                        .contains(element.displayName.toLowerCase()) &&
                    !update.description
                        .toLowerCase()
                        .contains(element.displayName.toLowerCase())) {
                  textList.add(element);
                }
                if (update.description
                    .toLowerCase()
                    .contains(element.displayName.toLowerCase())) {
                  textList.remove(element);
                }
              });
            }
          });
          contacts.forEach((s) {
            if (!_descriptionController.text.contains(s.displayName)) {
              s.displayName = '';
            }
          });

          for (int i = 0; i < textList.length; i++)
            await Provider.of<PrayerProvider>(context, listen: false)
                .removePrayerTag(textList[i].id);
          if (contacts.length > 0) {
            await Provider.of<PrayerProvider>(context, listen: false)
                .addPrayerTag(contacts, _user, _descriptionController.text, '');
          }
          BeStilDialog.hideLoading(context);
          Navigator.of(context).pushNamedAndRemoveUntil(
              EntryScreen.routeName, (Route<dynamic> route) => false);
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
    _descriptionController.text =
        widget.isEdit ? widget.prayerData.prayer.description : '';
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
      // String text = val;
      // // print(text);
      String text = val;

      print(text.substring(text.lastIndexOf('@')));
      // var newText = text.substring(text.indexOf('@'), text.indexOf(' '));
      // if (newText.contains('@')) {
      //   tagText = newText;
      // } else {
      //   tagText = '';
      // }
      // // print(tagText);
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
    if ((!widget.isEdit && _descriptionController.text.isNotEmpty) ||
        (widget.isEdit && _oldDescription != _descriptionController.text)) {
      onCancel();
      return true;
    } else {
      widget.setCurrentIndex(0, true);
      return (Navigator.of(context).pushNamedAndRemoveUntil(
              EntryScreen.routeName, (Route<dynamic> route) => false)) ??
          false;
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
                      if (widget.isEdit) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            EntryScreen.routeName,
                            (Route<dynamic> route) => false);
                      } else {
                        widget.setCurrentIndex(0, true);
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
    bool isValid = (!widget.isEdit && _descriptionController.text.isNotEmpty) ||
        (widget.isEdit && _oldDescription != _descriptionController.text);
    var positionOffset = 3.0;
    var positionOffset2 = 0.0;

    if (numberOfLines == 1.0) {
      positionOffset2 = 25;
    } else if (numberOfLines == 2.0) {
      positionOffset2 = 15;
    } else if (numberOfLines == 3.0) {
      positionOffset2 = 12;
    } else if (numberOfLines > 8) {
      positionOffset2 = 8;
    } else {
      positionOffset2 = 10;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
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
                          onTap: isValid
                              ? () => onCancel()
                              : widget.isEdit
                                  ? () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      Navigator.pop(context);
                                    }
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      widget.setCurrentIndex(0, true);
                                    },
                        ),
                        InkWell(
                          child: Text('SAVE',
                              style: AppTextStyles.boldText18.copyWith(
                                  color: !isValid
                                      ? AppColors.lightBlue5.withOpacity(0.5)
                                      : Colors.blue)),
                          onTap: () => isValid ? _save() : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Form(
                              autovalidate: _autoValidate,
                              key: _formKey,
                              child: Container(
                                child: CustomInput(
                                  textkey: _prayerKey,
                                  label: 'Prayer description',
                                  controller: _descriptionController,
                                  maxLines: 23,
                                  isRequired: true,
                                  showSuffix: false,
                                  textInputAction: TextInputAction.newline,
                                  onTextchanged: (val) => _onTextChange(val),
                                  focusNode: _focusNode,
                                ),
                              ),
                            ),
                          ),
                          tagText.length > 0
                              ? Positioned(
                                  top: ((numberOfLines * positionOffset) *
                                          positionOffset2) +
                                      (_descriptionController
                                              .selection.baseOffset /
                                          3),
                                  left: _focusNode.offset.dx,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
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
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                                  child: Text(
                                                    displayName,
                                                    style: AppTextStyles
                                                        .regularText14
                                                        .copyWith(
                                                      color:
                                                          AppColors.lightBlue4,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () => _onTagSelected(s));
                                          } else {
                                            return SizedBox();
                                          }
                                        }).toList(),
                                        tagList.length == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0),
                                                child: Text(
                                                  'No matching contacts found.',
                                                  style: AppTextStyles
                                                      .regularText14
                                                      .copyWith(
                                                    color: AppColors.lightBlue4,
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
