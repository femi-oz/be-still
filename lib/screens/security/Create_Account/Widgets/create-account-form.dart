import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/security/Create_Account/Widgets/terms_dialog.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateAccountForm extends StatefulWidget {
  final datePickerController;
  final dobController;
  final firstnameController;
  final lastnameController;
  final emailController;
  final formKey;
  final autoValidate;
  final passwordController;
  final confirmPasswordController;
  final selectDate;
  final agreeTerms;

  @override
  CreateAccountForm({
    this.datePickerController,
    this.dobController,
    this.formKey,
    this.autoValidate,
    this.emailController,
    this.firstnameController,
    this.lastnameController,
    this.passwordController,
    this.confirmPasswordController,
    this.selectDate,
    this.agreeTerms,
  });
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  DateTime _selectedDate = DateTime.now();

  _selectDate() async {
    FocusScope.of(context).unfocus();
    showDatePicker(
      context: context,
      initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime.now(),
    ).then((pickedDate) => {_dateTimeChanged(pickedDate)});
  }

  void _dateTimeChanged(DateTime pickedDate) {
    if (pickedDate == null) {
      return null;
    }
    setState(() {
      _selectedDate = pickedDate;
      widget.dobController.text =
          DateFormat('MM/dd/yyyy').format(_selectedDate);
    });
    widget.selectDate(pickedDate);
  }

  FocusNode focusNode;

  var termsAccepted = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        autovalidate: widget.autoValidate,
        child: Column(
          children: <Widget>[
            CustomInput(
              label: 'First Name',
              controller: widget.firstnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              label: 'Last Name',
              controller: widget.lastnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              label: 'Email',
              isEmail: true,
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            GestureDetector(
              onTap: () => _selectDate(),
              child: Container(
                color: Colors.transparent,
                child: IgnorePointer(
                  child: CustomInput(
                    label: 'Birthday',
                    controller: widget.dobController,
                    isRequired: true,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            CustomInput(
              isPassword: true,
              label: 'Password',
              controller: widget.passwordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              isPassword: true,
              label: 'Confirm Password',
              controller: widget.confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
              validator: (value) {
                if (widget.passwordController.text != value) {
                  return 'Password fields do not match';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              unfocus: true,
            ),
            SizedBox(height: 30.0),
            Column(
              children: <Widget>[
                InkWell(
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      'Read the Terms of Use/User Agreement',
                      style: AppTextStyles.regularText16,
                    ),
                  ),
                  onTap: () => createTermsDialog(context),
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Theme(
                      data: ThemeData(
                          unselectedWidgetColor: AppColors.lightBlue3),
                      child: Switch.adaptive(
                        value: termsAccepted,
                        onChanged: (val) {
                          setState(() {
                            widget.agreeTerms(val);
                            termsAccepted = val;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.lightBlue4,
                        inactiveThumbColor: Colors.white,
                      ),
                    ),
                    Text(
                      'I Agree to the Terms of Use',
                      style: AppTextStyles.regularText16,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
