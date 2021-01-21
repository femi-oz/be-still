import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/push_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/bs_raised_button.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/input_field.dart';
import '../Create_Account/create_account_screen.dart';
import '../Forget_Password/forget_password.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool _autoValidate = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _login() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    await BeStilDialog.showLoading(context, 'Authenticating');
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false).signIn(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      print(_usernameController.text + _passwordController.text);
      await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
      await PushNotificationsManager().init(Provider.of<UserProvider>(context, listen: false).currentUser.id);
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: 'Username or Password is incorrect.', key: _scaffoldKey);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundColor[0],
                  ...AppColors.backgroundColor,
                  ...AppColors.backgroundColor,
                ],
              ),
              image: DecorationImage(
                image: AssetImage(StringUtils.getBackgroundImage()),
                alignment: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Align(alignment: Alignment.topCenter, child: CustomLogoShape()),
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 260),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          // padding: EdgeInsets.symmetric(
                          //     vertical: 15.0, horizontal: 24.0),
                          padding: EdgeInsets.only(
                              top: 100, right: 24.0, left: 24.0, bottom: 15.0),

                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    _buildForm(),
                                    SizedBox(height: 8),
                                    _buildActions(),
                                  ],
                                ),
                              ),
                              _buildFooter(),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildForm() {
    return Form(
      autovalidate: _autoValidate,
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Username',
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            isEmail: true,
          ),
          SizedBox(height: 15.0),
          CustomInput(
            isPassword: true,
            label: 'Password',
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            isRequired: true,
            textInputAction: TextInputAction.done,
            unfocus: true,
            submitForm: () => _login(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          child: Text("Create an Account", style: AppTextStyles.regularText15),
          onTap: () {
            Navigator.of(context).pushNamed(CreateAccountScreen.routeName);
          },
        ),
        Row(
          children: <Widget>[
            Text('Remember Me', style: AppTextStyles.regularText15),
            SizedBox(width: 12),
            Switch.adaptive(
              activeColor: AppColors.lightBlue4,
              value: rememberMe,
              onChanged: (value) {
                setState(() => rememberMe = !rememberMe);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: <Widget>[
        BsRaisedButton(onPressed: _login),
        SizedBox(height: 24),
        GestureDetector(
          child: Text(
            "Forgot my Password",
            style: AppTextStyles.regularText13,
          ),
          onTap: () => Navigator.of(context).pushNamed(ForgetPassword.routeName),
        ),
      ],
    );
  }
}
