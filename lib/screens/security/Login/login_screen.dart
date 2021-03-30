import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
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
  bool showSuffix = true;

  Future<void> _isBiometricAvailable() async {
    try {
      var _isBioMetricAvailable = await _localAuthentication.canCheckBiometrics;
      setState(() => isBioMetricAvailable = _isBioMetricAvailable);
    } on PlatformException catch (e) {
      print(e);
    }

    isBioMetricAvailable
        ? _getListOfBiometricTypes()
        : print('No biometrics available');
  }

  // To retrieve the list of biometric types
  // (if available).
  Future<void> _getListOfBiometricTypes() async {
    try {
      if (Settings.enableLocalAuth) {
        listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
        setState(() {
          showSuffix = false;
          listOfBiometrics.forEach((e) {
            if (e.toString() == 'BiometricType.fingerprint') {
              showFingerPrint = true;
            } else if (e.toString() == 'BiometricType.face') {
              showFaceId = true;
              _biologin();
            } else {
              showFaceId = false;
              showFingerPrint = false;
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
              .navigateToReplacement(PrayerTime.routeName);
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

  var verificationSent = false;
  var verificationSendMessage = 'Resend verification email';
  var needsVerification = false;

  void _resendVerification() async {
    try {
      await BeStilDialog.showLoading(context, '');
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .sendEmailVerification();
      verificationSent = true;
      setState(() => verificationSendMessage =
          'Email verification sent. Please check your email');
      BeStilDialog.hideLoading(context);
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .signOut();
    } on HttpException catch (e) {
      verificationSent = false;
      setState(() => verificationSendMessage =
          'Resend verification email failed. Please try again');
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      verificationSent = false;
      setState(() => verificationSendMessage =
          'Resend verification email failed. Please try again');
      Provider.of<LogProvider>(context, listen: false).setErrorLog(e.toString(),
          _usernameController.text, 'LOGIN/screen/_resendVerification');
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
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
      needsVerification =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .needsVerification;
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      needsVerification =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .needsVerification;
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
      // await BeStilDialog.showLoading(context, 'Authenticating');

      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUser(true);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      Settings.lastUser = Settings.rememberMe ? jsonEncode(user.toJson2()) : '';
      Settings.userPassword =
          Settings.rememberMe ? _passwordController.text : '';
      await Provider.of<NotificationProvider>(context, listen: false)
          .setDevice(user.id);
      // BeStilDialog.hideLoading(context);
      await setRouteDestination();
    } on HttpException catch (e) {
      needsVerification =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .needsVerification;
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      needsVerification =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .needsVerification;
      Provider.of<LogProvider>(context, listen: false).setErrorLog(
          e.toString(), _usernameController.text, 'LOGIN/screen/_login');
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  _toggleBiometrics() {
    if (Settings.enableLocalAuth) {
      setState(() {
        Settings.enableLocalAuth = false;
        Settings.setenableLocalAuth = false;
        showSuffix = true;
      });
    } else {
      _openLogoutConfirmation(context);
      Settings.setenableLocalAuth = true;
      showSuffix = false;
    }
  }

  _openLogoutConfirmation(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Please login with your password to enable biometrics.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            // GestureDetector(
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'OK',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: MediaQuery.of(context).size.height,
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
                                    if (isBioMetricAvailable)
                                      InkWell(
                                        child: Container(
                                            // padding: EdgeInsets.only(
                                            //     left: 40, right: 60),
                                            child: Text(
                                          !Settings.enableLocalAuth
                                              ? 'Enable Face/Touch ID'
                                              : 'Disable Face/Touch ID',
                                          style: TextStyle(
                                              color: AppColors.lightBlue4),
                                        )),
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
      // height: 30,
      padding: EdgeInsets.only(
        left: 40,
      ),
      child: IconButton(
        icon: Icon(
            showFingerPrint && showFaceId
                ? Icons.face
                : !showFingerPrint && showFaceId
                    ? Icons.face
                    : Icons.fingerprint,
            color: AppColors.lightBlue4),
        onPressed: () => _biologin(),
        iconSize: 40,
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
        if (needsVerification && !verificationSent)
          InkWell(
            onTap: () => _resendVerification(),
            child: Text(
              verificationSendMessage,
              style: AppTextStyles.regularText13,
            ),
          ),
        if (verificationSent)
          Text(
            verificationSendMessage,
            style: AppTextStyles.regularText13,
          ),
        SizedBox(height: 20),
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
