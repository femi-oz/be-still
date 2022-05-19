import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CustomInput extends StatefulWidget {
  final int maxLines;
  final String label;
  final Color? color;
  final bool isPassword;
  final bool isGroup;
  final TextEditingController controller;
  final bool showSuffix;
  final TextInputAction textInputAction;
  final Function? submitForm;
  final Function? onTextchanged;
  final TextInputType? keyboardType;
  final bool isRequired;
  final String? Function(String)? validator;
  final bool isEmail;
  final bool obScurePassword;
  final double padding;
  final bool isPhone;
  final bool isLink;
  final bool unfocus;
  final FocusNode? focusNode;
  final bool isSearch;
  final GlobalKey? textkey;
  final bool hasBorder;

  CustomInput({
    this.maxLines = 1,
    required this.label,
    this.color,
    this.isPassword = false,
    this.isGroup = false,
    required this.controller,
    this.textkey,
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
    this.isSearch = false,
    this.hasBorder = true,
    this.focusNode,
  });

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _isTextNotEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        key: widget.textkey,
        inputFormatters:
            widget.isPhone ? [LengthLimitingTextInputFormatter(10)] : null,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.regularText15
            .copyWith(height: widget.maxLines > 1 ? 1.55 : 1),
        focusNode: widget.focusNode,
        cursorColor: widget.color == null ? AppColors.lightBlue4 : widget.color,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          suffixText: (widget.showSuffix && _isTextNotEmpty) ||
                  (widget.showSuffix && widget.controller.text != '')
              ? widget.label
              : '',
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 15, vertical: widget.padding),
          suffixStyle: AppTextStyles.regularText14.copyWith(
              color: Settings.isDarkMode
                  ? AppColors.offWhite2
                  : AppColors.prayerTextColor),
          counterText: '',
          hintText: widget.label,
          hintStyle: AppTextStyles.regularText15.copyWith(height: 1.5),
          errorBorder: new OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.redAccent),
          ),
          errorMaxLines: 5,
          errorStyle: AppTextStyles.errorText,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.hasBorder
                  ? AppColors.lightBlue4.withOpacity(0.5)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: widget.hasBorder
                    ? AppColors.lightBlue4
                    : Colors.transparent,
                width: 1.0),
          ),
          fillColor: AppColors.textFieldBackgroundColor,
          filled: true,
        ),
        obscureText: widget.obScurePassword,
        validator: (String? value) => _validatorFn(value ?? ""),
        onFieldSubmitted: (val) => {
          widget.isSearch ? _searchPrayer(val) : null,
          widget.unfocus
              ? FocusScope.of(context).unfocus()
              : FocusScope.of(context).nextFocus(),
          widget.unfocus ? widget.submitForm : null
        },
        textInputAction: widget.textInputAction,
        onChanged: (val) {
          setState(() => _isTextNotEmpty = val.isNotEmpty);
          if (widget.onTextchanged != null) widget.onTextchanged!(val);
        },
      ),
    );
  }

  void _searchPrayer(String value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchQuery(value);

    widget.isGroup
        ? await Provider.of<PrayerProviderV2>(context, listen: false)
            .searchGroupPrayers(value, userId ?? '')
        : await Provider.of<PrayerProviderV2>(context, listen: false)
            .searchPrayers(value, userId ?? '');
  }

  String? _validatorFn(String value) {
    if (widget.isRequired) {
      if (value.trim().isEmpty && widget.isEmail) {
        return 'Email is required';
      } else if (value.trim().isEmpty && widget.isPassword) {
        return 'Password is required';
      } else if (value.trim().isEmpty) {
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
      String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

      RegExp regExp = new RegExp(pattern);
      if (value.length != 10 || !regExp.hasMatch(value)) {
        return 'Enter a valid phone number';
      }
    }
    if (widget.isPassword && value.isNotEmpty) {
      String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Password must be at least 6 characters long and contain at least 1 lowercase, 1 uppercase, and 1 number.';
      }
    }
    if (widget.isLink && value.isNotEmpty) {
      String pattern =
          r'^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+(\.[a-z]{2,}){1,3}(#?\/?[a-zA-Z0-9#]+)*\/?(\?[a-zA-Z0-9-_]+=[a-zA-Z0-9-%]+&?)?$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) return 'Enter a valid url';
    }
    if (widget.validator != null) {
      return widget.validator!(value);
    }
    return null;
  }
}
