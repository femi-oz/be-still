import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgetPasswordTwo extends StatefulWidget {
  final codeController;
  final autoValidate;
  final formKey;
  final confirmcodeController;

  @override
  ForgetPasswordTwo(
      {this.formKey,
      this.autoValidate,
      this.codeController,
      this.confirmcodeController});
  _ForgetPasswordTwoState createState() => _ForgetPasswordTwoState();
}

class _ForgetPasswordTwoState extends State<ForgetPasswordTwo> {
  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidate: widget.autoValidate,
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Enter Code',
            controller: widget.codeController,
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          SizedBox(height: 10.0),
          CustomInput(
            label: 'Confirm Code',
            controller: widget.confirmcodeController,
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (widget.codeController.text != value) {
                return 'Password fields do not match';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            unfocus: true,
          ),
        ],
      ),
    );
  }
}
