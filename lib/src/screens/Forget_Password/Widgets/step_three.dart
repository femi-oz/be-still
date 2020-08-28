import 'package:be_still/src/widgets/input_field.dart';
import 'package:flutter/material.dart';

class ForgetPasswordThree extends StatefulWidget {
  final passwordController;
  final autoValidate;
  final formKey;
  final confirmPasswordController;

  @override
  ForgetPasswordThree(
      {this.formKey,
      this.autoValidate,
      this.passwordController,
      this.confirmPasswordController});
  _ForgetPasswordThreeState createState() => _ForgetPasswordThreeState();
}

class _ForgetPasswordThreeState extends State<ForgetPasswordThree> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidate: widget.autoValidate,
      child: Column(
        children: <Widget>[
          CustomInput(
            isPassword: true,
            label: 'New Password',
            controller: widget.passwordController,
            keyboardType: TextInputType.visiblePassword,
            isRequired: true,
          ),
          SizedBox(height: 10.0),
          CustomInput(
            isPassword: true,
            controller: widget.confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            isRequired: true,
            label: 'Confirm Password',
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
