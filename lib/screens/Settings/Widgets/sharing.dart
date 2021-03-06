import 'dart:io';

import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_edit_field.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
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
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings('churchName', _churchName.text);

      Navigator.pop(context);
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

  void _updateEmail() async {
    try {
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings('churchEmail', _churchEmail.text);
      Navigator.pop(context);
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

  void _updateLink() async {
    try {
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings('churchWebFormUrl', _churchLink.text);
      Navigator.pop(context);
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

  void _updatePhone() async {
    try {
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings('churchPhone', _churchPhone.text);
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProviderV2>(context);

    final phone = userProvider.currentUser.churchPhone != ''
        ? (userProvider.currentUser.churchPhone ?? '').replaceAllMapped(
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
                    value: (userProvider.currentUser.churchName ?? '') == ''
                        ? '---------'
                        : userProvider.currentUser.churchName ?? '',
                    onPressed: () {
                      _update(_ModalType.church, context);
                    },
                    showLabel: true,
                    label: 'Church',
                  ),
                  SizedBox(height: 15),
                  CustomEditField(
                    value: (userProvider.currentUser.churchEmail ?? '') == ''
                        ? '---------'
                        : userProvider.currentUser.churchEmail ?? '',
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
                    value:
                        (userProvider.currentUser.churchWebFormUrl ?? '') == ''
                            ? '---------'
                            : userProvider.currentUser.churchWebFormUrl ?? '',
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
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    _churchEmail.text = sharingSettings.churchEmail ?? '';
    _churchName.text = sharingSettings.churchName ?? '';
    _churchPhone.text = sharingSettings.churchPhone ?? '';
    _churchLink.text = sharingSettings.churchWebFormUrl ?? '';
    final alert = AlertDialog(
        insetPadding: EdgeInsets.all(10),
        backgroundColor: AppColors.backgroundColor[1],
        content: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width - 100,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Form(
                      autovalidateMode: _autoValidate == true
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      key: _formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.grey.withOpacity(0.5))),
                                  onPressed: () {
                                    _churchEmail.clear();
                                    _churchName.clear();
                                    _churchPhone.clear();
                                    _churchLink.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel',
                                      style: AppTextStyles.regularText15
                                          .copyWith(color: Colors.white))),
                              TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            AppColors.lightBlue3),
                                  ),
                                  onPressed: () {
                                    setState(() => _autoValidate = true);
                                    if (!_formKey.currentState!.validate())
                                      return null;
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
                                  child: Text('Save',
                                      style: AppTextStyles.regularText15
                                          .copyWith(color: Colors.white)))
                            ])
                      ]))
                ]))));
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
