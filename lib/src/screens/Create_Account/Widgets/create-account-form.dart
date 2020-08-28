import 'package:be_still/src/screens/Create_Account/Widgets/terms_dialog.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:be_still/src/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateAccountForm extends StatefulWidget {
  final datePickerController;
  final dobController;
  final fullnameController;
  final emailController;
  final formKey;
  final autoValidate;
  final passwordController;
  final confirmPasswordController;

  @override
  CreateAccountForm({
    this.datePickerController,
    this.dobController,
    this.formKey,
    this.autoValidate,
    this.emailController,
    this.fullnameController,
    this.passwordController,
    this.confirmPasswordController,
  });
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  DateTime _selectedDate = DateTime.now();

  _selectDate() async {
    // final DateTime picked = await showDatePicker(
    //   context: context,
    //   initialDate: selectedDate,
    //   firstDate: DateTime(1901, 1),
    //   lastDate: DateTime(2101),
    // );
    // if (picked != null && picked != selectedDate)
    //   setState(
    //     () {
    //       selectedDate = picked;
    //       final DateFormat formatter = DateFormat('MM/dd/yyyy');
    //       final String formatted = formatter.format(picked);
    //       widget.datePickerController.value = TextEditingValue(text: formatted);
    //     },
    //   );
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
              label: 'Full name',
              controller: widget.fullnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 10.0),
            CustomInput(
              label: 'Email',
              isEmail: true,
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            SizedBox(height: 10.0),
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
            SizedBox(height: 10.0),
            CustomInput(
              isPassword: true,
              label: 'Password',
              controller: widget.passwordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
            ),
            SizedBox(height: 10.0),
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
            ),
            SizedBox(height: 10.0),
            Column(
              children: <Widget>[
                InkWell(
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Read the Terms of Use/User Agreement',
                        style: TextStyle(
                          color: context.brightBlue2,
                          fontSize: 14,
                        ),
                      )),
                  onTap: () => createDialog(context),
                ),
                Row(
                  children: <Widget>[
                    Theme(
                      data:
                          ThemeData(unselectedWidgetColor: context.brightBlue),
                      child: Switch(
                        value: termsAccepted,
                        onChanged: (_) {
                          setState(() {
                            termsAccepted = !termsAccepted;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: context.switchThumbActive,
                        inactiveThumbColor: Colors.white,
                      ),
                    ),
                    Text(
                      'I Agree to the Terms of Use',
                      style: TextStyle(
                        color: context.brightBlue2,
                        fontSize: 14,
                      ),
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
