import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

class CustomInput extends StatelessWidget {
  final maxLines;
  final label;
  final color;
  final isPassword;
  final controller;
  final showSuffix;
  final textInputAction;
  // final focusNodeType;
  final keyboardType;
  final isRequired;
  final validator;
  final isEmail;
  final isPhone;
  final unfocus;

  CustomInput({
    this.maxLines = 1,
    @required this.label,
    this.color,
    this.isPassword = false,
    @required this.controller,
    this.showSuffix = true,
    this.textInputAction = TextInputAction.next,
    // this.focusNodeType,
    this.keyboardType,
    this.isRequired = false,
    this.validator,
    this.isPhone = false,
    this.isEmail = false,
    this.unfocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: color == null ? context.brightBlue2 : color,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.normal,
      ),
      maxLines: maxLines,
      decoration: InputDecoration(
        // prefixIcon: icon,
        // suffixIcon: isPassword == true
        //     ? IconButton(
        //         icon: Icon(
        //           obsurePassword ? Icons.visibility : Icons.visibility_off,
        //           color: color,
        //         ),
        //         onPressed: () {
        //           toggleVisibility();
        //         },
        //       )
        //     : null,
        suffixText: showSuffix ? label : '',
        suffixStyle: TextStyle(
          color: context.brightBlue2,
          fontSize: 14,
          fontWeight: FontWeight.w200,
        ),
        counterText: '',
        hintText: label,
        hintStyle: TextStyle(
          color: color == null ? context.brightBlue2 : color,
          fontSize: 14,
          fontWeight: FontWeight.w200,
        ),
        errorBorder: new OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.redAccent),
        ),
        errorMaxLines: 5,
        errorStyle: TextStyle(
          color: Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.normal,
        ),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.brightBlue2,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.brightBlue2,
            width: 1.0,
          ),
        ),
      ),
      obscureText: isPassword ? true : false,
      validator: (value) => _validatorFn(value),
      onFieldSubmitted: (_) => {
        unfocus
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).nextFocus()
      },
      textInputAction: textInputAction,
    );
  }

  String _validatorFn(String value) {
    if (isRequired) {
      if (value.isEmpty) {
        return 'Enter ${label.toLowerCase()}';
      }
    }
    if (isEmail && value.isNotEmpty) {
      String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
          "\\@" +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
          "(" +
          "\\." +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
          ")+";
      RegExp regExp = new RegExp(p);
      if (!regExp.hasMatch(value)) {
        return 'Enter a valid email address';
      }
    }
    if (isPhone && value.isNotEmpty) {
      String p = r'(^(?:[+234])?[0-9]{6,}$)';
      RegExp regExp = new RegExp(p);
      if (value.length < 6 || value.length > 15 || !regExp.hasMatch(value)) {
        return 'Enter a valid phone number';
      }
    }
    if (isPassword && value.isNotEmpty) {
      Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Password must be at least 6 characters long and contain at least 1 lowercase, 1 uppercase, and 1 number.';
    }
    if (validator != null) {
      return validator(value);
    }
    return null;
  }
}
