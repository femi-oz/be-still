import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/push_notification.dart';
import 'package:be_still/utils/string_utils.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool _autoValidate = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _key = GlobalKey<State>();

  void _login() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    await BeStilDialog.showLoading(context, _key, 'Authenticating');
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false).signIn(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
      await PushNotificationsManager().init(
          Provider.of<UserProvider>(context, listen: false).currentUser.id);
      BeStilDialog.hideLoading(_key);
      Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: 'Username or Password is incorrect.', key: _scaffoldKey);
    } catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.getBackgroundImage(
                  _themeProvider.isDarkModeEnabled)),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CustomLogoShape(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            _buildForm(),
                            _buildActions(),
                          ],
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            Switch.adaptive(
              activeColor: Colors.white,
              activeTrackColor: AppColors.lightBlue4,
              inactiveThumbColor: Colors.white,
              value: rememberMe,
              onChanged: (value) {
                setState(() {
                  rememberMe = !rememberMe;
                });
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
        GestureDetector(
          onTap: () => _login(),
          child: Container(
            height: 50.0,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.lightBlue1,
                  AppColors.lightBlue2,
                ],
              ),
            ),
            child: Icon(
              Icons.arrow_forward,
              color: AppColors.offWhite4,
            ),
          ),
        ),
        GestureDetector(
          child: Text(
            "Forget my Password",
            style: AppTextStyles.regularText13,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ForgetPassword.routeName);
          },
        ),
      ],
    );
  }
}
