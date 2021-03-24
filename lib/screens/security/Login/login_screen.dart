import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/bs_raised_button.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../widgets/input_field.dart';
import '../Create_Account/create_account_screen.dart';
import '../Forget_Password/forget_password.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool isBioMetricAvailable = false;
  List<BiometricType> listOfBiometrics;
  bool showFingerPrint = false;
  bool showFaceId = false;
  bool showBiometrics = false;
  bool showSuffix = false;

  Future<bool> _isBiometricAvailable() async {
    try {
      isBioMetricAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    isBioMetricAvailable
        ? _getListOfBiometricTypes()
        : print('No biometrics available');

    return isBioMetricAvailable;
  }

  // To retrieve the list of biometric types
  // (if available).
  Future<void> _getListOfBiometricTypes() async {
    try {
      if (Settings.enableLocalAuth) {
        this.showBiometrics = true;
        listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
        setState(() {
          listOfBiometrics.forEach((e) {
            if (e.toString() == 'BiometricType.fingerprint') {
              showFingerPrint = true;
            } else if (e.toString() == 'BiometricType.face') {
              showFaceId = true;
              _biologin();
            } else {
              showFaceId = false;
              showFingerPrint = false;
              this.showSuffix = false;
            }
          });
        });
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isBiometricAvailable();

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (Settings.lastUser.isNotEmpty) {
      var userInfo = jsonDecode(Settings.lastUser);
      _usernameController.text = userInfo['email'];
      _passwordController.text = Settings.userPassword;
    }
    super.initState();
  }

  Future<void> setRouteDestination() async {
    var message =
        Provider.of<NotificationProvider>(context, listen: false).message;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (message.type == NotificationType.prayer_time) {
          await Provider.of<PrayerProvider>(context, listen: false)
              .setPrayerTimePrayers(message.entityId);
          NavigationService.instance
              .navigateToReplacement(PrayerMode.routeName);
        }
        if (message.type == NotificationType.prayer) {
          await Provider.of<PrayerProvider>(context, listen: false)
              .setPrayer(message.entityId);
          NavigationService.instance
              .navigateToReplacement(PrayerDetails.routeName);
        }
      });
      Provider.of<NotificationProvider>(context, listen: false).clearMessage();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    }
  }

  void _login() async {
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();
    await BeStilDialog.showLoading(context, 'Authenticating');
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false).signIn(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUser(false);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      Settings.lastUser = Settings.rememberMe ? jsonEncode(user.toJson2()) : '';
      Settings.userPassword =
          Settings.rememberMe ? _passwordController.text : '';
      await Provider.of<NotificationProvider>(context, listen: false)
          .setDevice(user.id);
      LocalNotification.setNotificationsOnNewDevice(context);
      BeStilDialog.hideLoading(context);
      await setRouteDestination();
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .signOut();
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), _usernameController.text, 'LOGIN/screen/_login');
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  void _biologin() async {
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .biometricSignin();
      await BeStilDialog.showLoading(context, 'Authenticating');

      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUser(true);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      Settings.lastUser = Settings.rememberMe ? jsonEncode(user.toJson2()) : '';
      Settings.userPassword =
          Settings.rememberMe ? _passwordController.text : '';
      await Provider.of<NotificationProvider>(context, listen: false)
          .setDevice(user.id);
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushNamedAndRemoveUntil(
        EntryScreen.routeName,
        (Route<dynamic> route) => false,
      );
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .signOut();
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), _usernameController.text, 'LOGIN/screen/_login');
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  _toggleBiometrics() {
    if (!Settings.enableLocalAuth) {
      setState(() {
        Settings.enableLocalAuth = true;
      });
    } else {
      setState(() {
        Settings.enableLocalAuth = false;
      });
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
                image: AssetImage(StringUtils.backgroundImage()),
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
                        SizedBox(height: 220),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
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
                                    SizedBox(height: 10),
                                    InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 40, right: 60),
                                        child: Settings.lastUser != ''
                                            ? Text(
                                                !Settings.enableLocalAuth
                                                    ? 'Enable Face/Touch ID'
                                                    : 'Disable Face/Touch ID',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.lightBlue4),
                                              )
                                            : Container(),
                                      ),
                                      onTap: _toggleBiometrics,
                                    )
                                    // showFingerPrint || showFaceId
                                    //     ? _bioButton()
                                    //     : Container(),
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

  Widget _bioButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 40,
      ),
      child: IconButton(
        icon: Icon(showFingerPrint ? Icons.fingerprint : Icons.face,
            color: AppColors.lightBlue4),
        onPressed: () => _biologin(),
        iconSize: 50,
      ),
    );
  }

  void _setDefaults() {
    Settings.rememberMe = false;
    setState(() => Settings.enableLocalAuth = false);
  }

  Widget _buildForm() {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Username',
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            isEmail: true,
            onTextchanged: () => _usernameController.text !=
                    jsonDecode(Settings.lastUser)['email']
                ? _setDefaults
                : null,
          ),
          SizedBox(height: 15.0),
          Stack(
            children: [
              Align(
                child: CustomInput(
                  obScurePassword: true,
                  label: 'Password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  isRequired: true,
                  textInputAction: TextInputAction.done,
                  unfocus: true,
                  submitForm: () => _login(),
                  showSuffix: showSuffix,
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Settings.enableLocalAuth ? _bioButton() : Container())
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActions() {
    var _remeberMe = Settings.rememberMe;
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
              value: _remeberMe,
              onChanged: (value) => setState(() => Settings.rememberMe = value),
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
        // Settings.enableLocalAuth
        //     ? BsRaisedButton(
        //         onPressed: _biologin,
        //       )
        //     : Container(),
        SizedBox(height: 24),
        GestureDetector(
          child: Text(
            "Forgot my Password",
            style: AppTextStyles.regularText13,
          ),
          onTap: () =>
              Navigator.of(context).pushNamed(ForgetPassword.routeName),
        ),
      ],
    );
  }
}
