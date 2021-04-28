import 'dart:async';

import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';
import 'package:provider/provider.dart';

class CustomInput extends StatefulWidget {
  final int maxLines;
  final String label;
  final Color color;
  final bool isPassword;
  final TextEditingController controller;
  final bool showSuffix;
  final TextInputAction textInputAction;
  final Function submitForm;
  final Function onTextchanged;
  final TextInputType keyboardType;
  final bool isRequired;
  final validator;
  final bool isEmail;
  final bool obScurePassword;
  final double padding;
  final bool isPhone;
  final bool isLink;
  final bool unfocus;
  final FocusNode focusNode;

  CustomInput(
      {this.maxLines = 1,
      @required this.label,
      this.color,
      this.isPassword = false,
      @required this.controller,
      this.showSuffix = true,
      this.textInputAction = TextInputAction.done,
      this.submitForm,
      this.onTextchanged,
      this.keyboardType,
      this.isRequired = false,
      this.validator,
      this.obScurePassword = false,
      this.padding = 20.0,
      this.isPhone = false,
      this.isEmail = false,
      this.isLink = false,
      this.unfocus = false,
      this.focusNode});

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _isTextNotEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.isPhone
          ? MaskedTextField(
              maskedTextFieldController: widget.controller,
              mask: "(xxx) xxx-xxxx",
              maxLength: 14,
              keyboardType: TextInputType.number,
              inputDecoration: InputDecoration(
                suffixText: (widget.showSuffix && _isTextNotEmpty) ||
                        (widget.showSuffix && widget.controller.text != '')
                    ? widget.label
                    : '',
                // suffixIcon: widget.showBiometric
                //     ? IconButton(
                //         icon: Icon(
                //             widget.showFaceId ? Icons.face : Icons.fingerprint),
                //         onPressed: () {
                //           // widget.bioLogin;
                //         })
                //     : Container(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 15, vertical: widget.padding),
                suffixStyle: AppTextStyles.regularText14.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite2
                        : AppColors.grey4),
                counterText: '',
                hintText:
                    widget.isRequired ? '${widget.label} \*' : widget.label,
                hintStyle: AppTextStyles.regularText15.copyWith(height: 1.5),
                errorBorder: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.redAccent),
                ),
                errorMaxLines: 5,
                errorStyle: AppTextStyles.errorText,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.lightBlue4.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.lightBlue4, width: 1.0),
                ),
                fillColor: AppColors.textFieldBackgroundColor,
                filled: true,
              ),
            )
          : TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.regularText15,
              focusNode: widget.focusNode,
              cursorColor:
                  widget.color == null ? AppColors.lightBlue4 : widget.color,
              maxLines: widget.maxLines,
              decoration: InputDecoration(
                suffixText: (widget.showSuffix && _isTextNotEmpty) ||
                        (widget.showSuffix && widget.controller.text != '')
                    ? widget.label
                    : '',
                // suffixIcon: widget.showBiometric
                //     ? IconButton(
                //         icon: Icon(
                //             widget.showFaceId ? Icons.face : Icons.fingerprint),
                //         onPressed: () {
                //           // widget.bioLogin;
                //         })
                //     : Container(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 15, vertical: widget.padding),
                suffixStyle: AppTextStyles.regularText14.copyWith(
                    color: Settings.isDarkMode
                        ? AppColors.offWhite2
                        : AppColors.prayerTextColor),
                counterText: '',
                hintText:
                    widget.isRequired ? '${widget.label} \*' : widget.label,
                hintStyle: AppTextStyles.regularText15.copyWith(height: 1.5),
                errorBorder: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.redAccent),
                ),
                errorMaxLines: 5,
                errorStyle: AppTextStyles.errorText,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.lightBlue4.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.lightBlue4, width: 1.0),
                ),
                fillColor: AppColors.textFieldBackgroundColor,
                filled: true,
              ),
              obscureText: widget.obScurePassword,
              validator: (value) => _validatorFn(value),
              onFieldSubmitted: (_) => {
                    widget.unfocus
                        ? FocusScope.of(context).unfocus()
                        : FocusScope.of(context).nextFocus(),
                    widget.unfocus ? widget.submitForm : null
                  },
              textInputAction: widget.textInputAction,
              onChanged: (val) {
                setVisibilty(val);
                setState(() => _isTextNotEmpty = val != null && val.isNotEmpty);
                if (widget.onTextchanged != null) widget.onTextchanged(val);
              }),
    );
  }

  void setVisibilty(String value) {
    Pattern passwordPattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
    RegExp regex = new RegExp(passwordPattern);
    Pattern emailPattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(emailPattern);
    if (widget.isRequired) {
      if (value.isNotEmpty) {
        Provider.of<MiscProvider>(context, listen: false).setVisibility(false);
      } else {
        Provider.of<MiscProvider>(context, listen: false).setVisibility(true);
      }
    }
    if (value.contains(regExp) || value.contains(regex)) {
      Provider.of<MiscProvider>(context, listen: false).setVisibility(false);
    } else {
      Provider.of<MiscProvider>(context, listen: false).setVisibility(true);
    }
  }

  String _validatorFn(String value) {
    if (widget.isRequired) {
      //  if (value.isEmpty ) {
      //   return '${widget.label} is required';
      // }
      if (value.isEmpty && widget.isEmail) {
        return 'Email is required';
      } else if (value.isEmpty && widget.isPassword) {
        return 'Password is required';
      } else if (value.isEmpty) {
        return '${widget.label} is required';
      }
    }
    if (widget.isEmail && value.isNotEmpty) {
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
    if (widget.isPhone && value.isNotEmpty) {
      String p = r'(^(?:[+234])?[0-9]{6,}$)';
      RegExp regExp = new RegExp(p);
      if (value.length < 6 || value.length > 15 || !regExp.hasMatch(value)) {
        return 'Enter a valid phone number';
      }
    }
    if (widget.isPassword && value.isNotEmpty && widget.validator != 'null') {
      Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Password must be at least 6 characters long and contain at least 1 lowercase, 1 uppercase, and 1 number.';
      }
    }
    if (widget.isLink && value.isNotEmpty) {
      Pattern pattern =
          r'^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+(\.[a-z]{2,}){1,3}(#?\/?[a-zA-Z0-9#]+)*\/?(\?[a-zA-Z0-9-_]+=[a-zA-Z0-9-%]+&?)?$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) return 'Enter a valid url';
    }
    if (widget.validator != null) {
      return widget.validator(value);
    }
    return null;
  }
}
