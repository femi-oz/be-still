import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_edit_field.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SharingSettings extends StatefulWidget {
  @override
  _SharingSettingsState createState() => _SharingSettingsState();
}

enum _ModalType { church, email, phone, link }

class _SharingSettingsState extends State<SharingSettings> {
  TextEditingController _churchName = TextEditingController();
  TextEditingController _churchPhone = TextEditingController();
  TextEditingController _churchEmail = TextEditingController();
  TextEditingController _churchLink = TextEditingController();
  bool showChurchEditField = false;
  bool showEmailEditField = false;
  bool showPhoneEditField = false;
  bool showUrlEditField = false;

  void _updateChurch() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchName,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchName.text);

      Navigator.pop(context);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void _updateEmail() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchEmail,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchEmail.text);
      Navigator.pop(context);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void _updateLink() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.webFormLink,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchLink.text);
      Navigator.pop(context);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void _updatePhone() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchPhone,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchPhone.text);
      Navigator.pop(context);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingsProvider>(context);

    final phone = settingProvider.sharingSettings.churchPhone != ''
        ? settingProvider.sharingSettings.churchPhone.replaceAllMapped(
            RegExp(r'(\d{3})(\d{3})(\d+)'),
            (Match m) => "(${m[1]}) ${m[2]}-${m[3]}")
        : '---------';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Column(
                children: [
                  CustomSectionHeder('With My Church'),
                  SizedBox(height: 35),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Set your Church\'s preferred method of submitting prayers here to save it as a quick selection in the sharing options.',
                      style: AppTextStyles.regularText15
                          .copyWith(color: AppColors.textFieldText),
                    ),
                  ),
                  SizedBox(height: 35),
                  CustomEditField(
                    value: settingProvider.sharingSettings.churchName == ''
                        ? '---------'
                        : settingProvider.sharingSettings.churchName,
                    onPressed: () {
                      _update(_ModalType.church, context);
                    },
                    showLabel: true,
                    label: 'Church',
                  ),
                  SizedBox(height: 15),
                  CustomEditField(
                    value: settingProvider.sharingSettings.churchEmail == ''
                        ? '---------'
                        : settingProvider.sharingSettings.churchEmail,
                    onPressed: () {
                      _update(_ModalType.email, context);
                    },
                    showLabel: true,
                    label: 'Email',
                  ),
                  SizedBox(height: 15),
                  CustomEditField(
                    value: phone,
                    onPressed: () {
                      _update(_ModalType.phone, context);
                    },
                    showLabel: true,
                    label: 'Phone (mobile only)',
                  ),
                  SizedBox(height: 15),
                  CustomEditField(
                    value: settingProvider.sharingSettings.webFormlink == ''
                        ? '---------'
                        : settingProvider.sharingSettings.webFormlink,
                    onPressed: () {
                      _update(_ModalType.link, context);
                    },
                    showLabel: true,
                    label: 'Web Prayer Form',
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _update(_ModalType type, ctx) {
    final _formKey = GlobalKey<FormState>();
    bool _autoValidate = false;
    final sharingSettings =
        Provider.of<SettingsProvider>(context, listen: false).sharingSettings;
    _churchEmail.text = sharingSettings.churchEmail;
    _churchName.text = sharingSettings.churchName;
    _churchPhone.text = sharingSettings.churchPhone;
    _churchLink.text = sharingSettings.webFormlink;
    final alert = AlertDialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: AppColors.backgroundColor[1],
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                // ignore: deprecated_member_use
                // autovalidate: _autoValidate,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == _ModalType.email)
                      Text(
                        'Update  Email',
                        style: AppTextStyles.boldText20,
                      )
                    else if (type == _ModalType.church)
                      Text(
                        'Update  Church',
                        style: AppTextStyles.boldText20,
                      )
                    else if (type == _ModalType.link)
                      Text(
                        'Update Web Prayer Form',
                        style: AppTextStyles.boldText20,
                      )
                    else if (type == _ModalType.phone)
                      Text(
                        'Update Phone',
                        style: AppTextStyles.boldText20,
                      ),
                    SizedBox(height: 10.0),
                    type == _ModalType.church
                        ? CustomInput(
                            isSearch: false,
                            isRequired: false,
                            showSuffix: false,
                            label: 'Enter Church Name',
                            controller: _churchName)
                        : type == _ModalType.email
                            ? CustomInput(
                                isSearch: false,
                                isRequired: false,
                                showSuffix: false,
                                keyboardType: TextInputType.emailAddress,
                                isEmail: true,
                                label: 'Enter Church Email',
                                controller: _churchEmail)
                            : type == _ModalType.phone
                                ? CustomInput(
                                    isSearch: false,
                                    isRequired: false,
                                    showSuffix: false,
                                    keyboardType: TextInputType.number,
                                    isPhone: true,
                                    label: 'Enter Church Phone',
                                    controller: _churchPhone)
                                : type == _ModalType.link
                                    ? CustomInput(
                                        isSearch: false,
                                        isLink: false,
                                        isRequired: false,
                                        showSuffix: false,
                                        label:
                                            'Enter Church Web Prayer Form Link',
                                        controller: _churchLink)
                                    : SizedBox.shrink(),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.grey.withOpacity(0.5)),
                          ),
                          onPressed: () {
                            _churchEmail.clear();
                            _churchName.clear();
                            _churchPhone.clear();
                            _churchLink.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.regularText15.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.lightBlue3),
                          ),
                          onPressed: () {
                            setState(() => _autoValidate = true);
                            if (!_formKey.currentState!.validate()) return null;
                            _formKey.currentState!.save();
                            switch (type) {
                              case _ModalType.church:
                                _updateChurch();
                                break;
                              case _ModalType.email:
                                _updateEmail();
                                break;
                              case _ModalType.phone:
                                _updatePhone();
                                break;
                              case _ModalType.link:
                                _updateLink();
                                break;
                              default:
                            }
                          },
                          child: Text(
                            'Submit',
                            style: AppTextStyles.regularText15.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
