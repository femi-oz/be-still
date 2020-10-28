import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';

class ForgetPasswordOne extends StatefulWidget {
  final usernameController;
  final autoValidate;
  final formKey;

  @override
  ForgetPasswordOne({
    this.formKey,
    this.autoValidate,
    this.usernameController,
  });
  _ForgetPasswordOneState createState() => _ForgetPasswordOneState();
}

enum CodeType {
  email,
  text,
}

class _ForgetPasswordOneState extends State<ForgetPasswordOne> {
  CodeType type = CodeType.email;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidate: widget.autoValidate,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Username',
            controller: widget.usernameController,
            keyboardType: TextInputType.text,
            isRequired: true,
            textInputAction: TextInputAction.done,
            unfocus: true,
          ),
          SizedBox(height: 40.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'How would you like to recieve your password reset code?',
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText16b,
            ),
          ),
          SizedBox(height: 55.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: type == CodeType.email
                      ? context.toolsActiveBtn.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.inputFieldBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FlatButton(
                  child: Text(
                    'EMAIL',
                    style: AppTextStyles.regularText16,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        type = CodeType.email;
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.42,
                decoration: BoxDecoration(
                  color: type == CodeType.text
                      ? context.toolsActiveBtn.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: context.inputFieldBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FlatButton(
                  child: Text(
                    'TEXT',
                    style: AppTextStyles.regularText16,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        type = CodeType.text;
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
