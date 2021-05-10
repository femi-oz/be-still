import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
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
    if (_churchName.text == null || _churchName.text.trim() == '') {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      PlatformException er = PlatformException(
          code: 'custom',
          message: 'Church name can not be empty, please enter a valid name');

      BeStilDialog.showErrorDialog(context, er, user, null);
    } else {
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
        setState(() {
          showChurchEditField = false;
        });
        // Navigator.pop(context);
      } catch (e, s) {
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(context, e, user, s);
      }
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
      setState(() {
        showEmailEditField = false;
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
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
      setState(() {
        showUrlEditField = false;
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
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
      setState(() {
        showPhoneEditField = false;
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void toggleForm(String formToEdit) {
    setState(() {
      switch (formToEdit) {
        case 'church':
          showChurchEditField = true;
          break;
        case 'email':
          showEmailEditField = true;
          break;
        case 'phone':
          showPhoneEditField = true;
          break;
        case 'url':
          showUrlEditField = true;
          break;
        // default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingsProvider>(context);
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
                  !showChurchEditField
                      ? CustomEditField(
                          value:
                              settingProvider.sharingSettings.churchName == ''
                                  ? '---------'
                                  : settingProvider.sharingSettings.churchName,
                          onPressed: () {
                            toggleForm('church');
                          },
                          showLabel: true,
                          label: 'Church',
                        )
                      : _update(_ModalType.church, context),
                  SizedBox(height: 15),
                  !showEmailEditField
                      ? CustomEditField(
                          value:
                              settingProvider.sharingSettings.churchEmail == ''
                                  ? '---------'
                                  : settingProvider.sharingSettings.churchEmail,
                          onPressed: () {
                            toggleForm('email');
                          },
                          showLabel: true,
                          label: 'Email',
                        )
                      : _update(_ModalType.email, context),
                  SizedBox(height: 15),
                  !showPhoneEditField
                      ? CustomEditField(
                          value:
                              settingProvider.sharingSettings.churchPhone == ''
                                  ? '---------'
                                  : settingProvider.sharingSettings.churchPhone,
                          onPressed: () {
                            toggleForm('phone');
                          },
                          showLabel: true,
                          label: 'Phone (mobile only)',
                        )
                      : _update(_ModalType.phone, context),
                  SizedBox(height: 15),
                  !showUrlEditField
                      ? CustomEditField(
                          value:
                              settingProvider.sharingSettings.webFormlink == ''
                                  ? '---------'
                                  : settingProvider.sharingSettings.webFormlink,
                          onPressed: () {
                            toggleForm('url');
                          },
                          showLabel: true,
                          label: 'Web Prayer Form',
                        )
                      : _update(_ModalType.link, context),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _update(_ModalType type, ctx) {
    final sharingSettings =
        Provider.of<SettingsProvider>(context, listen: false).sharingSettings;
    _churchEmail.text = sharingSettings.churchEmail;
    _churchName.text = sharingSettings.churchName;
    _churchPhone.text = sharingSettings.churchPhone;
    _churchLink.text = sharingSettings.webFormlink;

    final _formKey = GlobalKey<FormState>();
    return Container(
      padding: EdgeInsets.only(right: 39),
      width: MediaQuery.of(context).size.width - 40,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            type == _ModalType.church
                ? CustomInput(
                    isRequired: true,
                    showSuffix: false,
                    label: 'Enter Church Name',
                    controller: _churchName)
                : type == _ModalType.email
                    ? CustomInput(
                        isRequired: true,
                        showSuffix: false,
                        keyboardType: TextInputType.emailAddress,
                        isEmail: true,
                        label: 'Enter Church Email',
                        controller: _churchEmail)
                    : type == _ModalType.phone
                        ? CustomInput(
                            isRequired: true,
                            showSuffix: false,
                            keyboardType: TextInputType.phone,
                            isPhone: true,
                            label: 'Enter Church Phone',
                            controller: _churchPhone)
                        : type == _ModalType.link
                            ? CustomInput(
                                isLink: true,
                                isRequired: true,
                                showSuffix: false,
                                label: 'Enter Church Web Prayer Form Link',
                                controller: _churchLink)
                            : null,
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.grey.withOpacity(0.5)),
                  ),
                  onPressed: () => setState(() {
                    if (showChurchEditField)
                      showChurchEditField = false;
                    else if (showEmailEditField)
                      showEmailEditField = false;
                    else if (showPhoneEditField)
                      showPhoneEditField = false;
                    else if (showUrlEditField)
                      showUrlEditField = false;
                    else
                      return;
                  }),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.regularText15.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.lightBlue3),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState.validate()) return null;
                    _formKey.currentState.save();

                    if (type == _ModalType.church) _updateChurch();

                    if (type == _ModalType.email) _updateEmail();
                    if (type == _ModalType.link) _updateLink();
                    if (type == _ModalType.phone) _updatePhone();
                  },
                  child: Text('Save',
                      style: AppTextStyles.regularText15.copyWith(
                        color: Colors.white,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _button(
      {final String actionText, final String value, final Function onPressed}) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textFieldBorder,
            ),
            borderRadius: BorderRadius.circular(3.0),
            color: AppColors.textFieldBackgroundColor),
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Row(children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: AppTextStyles.regularText18b
                  .copyWith(color: AppColors.lightBlue4),
            ),
          ),
          SizedBox(width: 15),
          Text(actionText,
              textAlign: TextAlign.end,
              style: AppTextStyles.regularText18b
                  .copyWith(color: AppColors.prayerTextColor)),
        ]),
      ),
    );
  }
}
