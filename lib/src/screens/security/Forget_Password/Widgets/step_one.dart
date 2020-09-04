import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:be_still/src/widgets/input_field.dart';
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

class _ForgetPasswordOneState extends State<ForgetPasswordOne> {
  String type = 'email';

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
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Text(
              'How would you like to recieve your password reset code?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.inputFieldText,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 15),
                height: 30,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: type == 'email'
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
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        type = 'email';
                      },
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                height: 30,
                width: MediaQuery.of(context).size.width * 0.42,
                decoration: BoxDecoration(
                  color: type == 'text'
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
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        type = 'text';
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
