import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/debouncer.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/bs_raised_button.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import 'package:provider/provider.dart';
import '../../../widgets/input_field.dart';
import '../Create_Account/create_account_screen.dart';
import '../Forget_Password/forget_password.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _passwordKey = GlobalKey();
  final _usernameKey = GlobalKey();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final _debounce = Debouncer(delay: const Duration(seconds: 1));
  List<BiometricType> listOfBiometrics = [];
  String verificationSendMessage = 'Resend verification email';

  bool rememberMe = false;
  bool isBioMetricAvailable = false;
  bool showFingerPrint = false;
  bool showFaceId = false;
  bool showSuffix = true;
  bool _autoValidate = false;
  bool verificationSent = false;
  bool isLoading = false;
  bool needsVerification = false;

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
      setState(() => isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty);
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        await _isBiometricAvailable();
        bool showBioAuth =
            (ModalRoute.of(context)?.settings.arguments ?? false) as bool;
        if (showBioAuth && isBioMetricAvailable && Settings.enableLocalAuth)
          _biologin();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (Settings.rememberMe && Settings.lastUser.isNotEmpty) {
      var userInfo = jsonDecode(Settings.lastUser);
      _usernameController.text = userInfo['email'];
      _passwordController.text = Settings.userPassword;
    }
    initDynamicLinks();
    super.initState();
  }

  Future<void> initDynamicLinks() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        var actionCode = deepLink.queryParameters['oobCode'];
        try {
          await auth.checkActionCode(actionCode ?? '');
          await auth.applyActionCode(actionCode ?? '');
          showInfoDialog(context);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-action-code') {
            print('The code is invalid.');
          }
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      var actionCode = deepLink.queryParameters['oobCode'];
      try {
        await auth.checkActionCode(actionCode ?? '');
        await auth.applyActionCode(actionCode ?? '');
        showInfoDialog(context);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-action-code') {
          print('The code is invalid.');
        }
      }
    }
  }

  showInfoDialog(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10.0),
          Flexible(
            child: Text(
              'Your account has been successfully verified. \n\n Login to continue!',
              style: AppTextStyles.regularText16b
                  .copyWith(color: AppColors.lightBlue4),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    child: Text('OK',
                        style: AppTextStyles.boldText16
                            .copyWith(color: Colors.white)),
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                          AppTextStyles.boldText16
                              .copyWith(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(5.0)),
                      elevation: MaterialStateProperty.all<double>(0.0),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<void> setRouteDestination() async {
    try {
      final message =
          Provider.of<NotificationProviderV2>(context, listen: false).message;
      if ((message.entityId ?? '').isNotEmpty) {
        if (message.type == NotificationType.prayer_time) {
          await Provider.of<PrayerProviderV2>(context, listen: false)
              .setPrayerTimePrayers();
          AppController appController = Get.find();
          appController.setCurrentPage(2, false, 0);
          Provider.of<MiscProviderV2>(context, listen: false)
              .setLoadStatus(true);
          Navigator.of(context).pushNamedAndRemoveUntil(
              EntryScreen.routeName, (Route<dynamic> route) => false);
        }
        if (message.type == NotificationType.prayer) {
          Provider.of<PrayerProviderV2>(context, listen: false)
              .setCurrentPrayerId(message.entityId ?? '');
        }
        Provider.of<NotificationProviderV2>(context, listen: false)
            .clearMessage();
      } else {
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setLoadStatus(true);
        AppController appController = Get.find();

        appController.setCurrentPage(0, false, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false);
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void _resendVerification() async {
    try {
      BeStilDialog.showLoading(context, '');
      await Provider.of<AuthenticationProviderV2>(context, listen: false)
          .sendEmailVerification();
      verificationSent = true;
      setState(() => verificationSendMessage =
          'Email verification sent. Please check your email');
      BeStilDialog.hideLoading(context);
      await Provider.of<AuthenticationProviderV2>(context, listen: false)
          .signOut();
    } on HttpException catch (e, s) {
      verificationSent = false;
      setState(() => verificationSendMessage =
          'Resend verification email failed. Please try again');
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    } catch (e, s) {
      verificationSent = false;
      setState(() => verificationSendMessage =
          'Resend verification email failed. Please try again');

      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(
          context, StringUtils.errorOccured, UserDataModel(), s);
    }
  }

  void _login() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    BeStilDialog.showLoading(context, 'Authenticating');
    try {
      await Provider.of<AuthenticationProviderV2>(context, listen: false)
          .signIn(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      await Provider.of<UserProviderV2>(context, listen: false)
          .setCurrentUser(false);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;

      Settings.lastUser = jsonEncode(user.toJson2());
      Settings.userPassword = _passwordController.text;
      if (Settings.enabledReminderPermission)
        LocalNotification.setNotificationsOnNewDevice(context);

      BeStilDialog.hideLoading(context);
      await setRouteDestination();
    } on HttpException catch (e, s) {
      needsVerification =
          e.message == StringUtils.generateExceptionMessage('not-verified');

      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    } catch (e, s) {
      needsVerification =
          Provider.of<AuthenticationProviderV2>(context, listen: false)
              .needsVerification;

      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(
          context, StringUtils.errorOccured, UserDataModel(), s);
    }
  }

  Future<void> _biologin() async {
    try {
      final userInfo = jsonDecode(Settings.lastUser);
      final usernname = userInfo['email'];
      final password = Settings.userPassword;
      await Provider.of<AuthenticationProviderV2>(context, listen: false)
          .signIn(
        email: usernname,
        password: password,
      );
      final isAuth =
          await Provider.of<AuthenticationProviderV2>(context, listen: false)
              .biometricSignin();
      BeStilDialog.showLoading(context, 'Authenticating');
      isLoading = true;
      if (isAuth) {
        await Provider.of<UserProviderV2>(context, listen: false)
            .setCurrentUser(false);
        BeStilDialog.hideLoading(context);
        isLoading = false;

        await setRouteDestination();
      } else {
        BeStilDialog.hideLoading(context);
        isLoading = false;
      }
    } on HttpException catch (e, s) {
      if (isLoading) {
        BeStilDialog.hideLoading(context);
        isLoading = false;
      }
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    } catch (e, s) {
      if (isLoading) {
        BeStilDialog.hideLoading(context);
        isLoading = false;
      }

      BeStilDialog.showErrorDialog(
          context, StringUtils.errorOccured, UserDataModel(), s);
    }
  }

  _toggleBiometrics() {
    if (Settings.enableLocalAuth) {
      Settings.enableLocalAuth = false;
      Settings.setenableLocalAuth = false;
      showSuffix = true;
    } else {
      _openBioConfirmation(context);
      Settings.setenableLocalAuth = true;
      showSuffix = false;
    }
    setState(() {});
  }

  _openBioConfirmation(BuildContext context) {
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
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              child: Text(
                'Biometrics will be enabled after you log in.',
                textAlign: TextAlign.center,
                style: AppTextStyles.regularText16b
                    .copyWith(color: AppColors.lightBlue1),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextButton(
                child: Text('OK',
                    style:
                        AppTextStyles.boldText16.copyWith(color: Colors.white)),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      AppTextStyles.boldText16.copyWith(color: Colors.white)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(5.0)),
                  elevation: MaterialStateProperty.all<double>(0.0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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

  Future<bool> _onWillPop() async {
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         LoginScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  bool isFormValid = false;

  @override
  Widget build(BuildContext context) {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      isFormValid = true;
    } else {
      isFormValid = false;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            key: _scaffoldKey,
            body: Container(
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
              ),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter, child: CustomLogoShape()),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: new LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(StringUtils.backgroundImage),
                                alignment: Alignment.bottomCenter,
                                fit: BoxFit.cover,
                                colorFilter: new ColorFilter.mode(
                                    AppColors.backgroundColor[0]
                                        .withOpacity(0.2),
                                    BlendMode.dstATop),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.43),
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  width: double.infinity,
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          _buildForm(),
                                          SizedBox(height: 8),
                                          _buildActions(),
                                          SizedBox(height: 10),
                                          if (isBioMetricAvailable)
                                            InkWell(
                                              child: Container(
                                                  child: Text(
                                                !Settings.enableLocalAuth
                                                    ? 'Enable Face/Touch ID'
                                                    : 'Disable Face/Touch ID',
                                                style:
                                                    AppTextStyles.regularText15,
                                              )),
                                              onTap: _toggleBiometrics,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 30),
                                      _buildFooter(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _bioButton() {
    return Container(
      width: 50.0,
      height: 50.0,
      margin: EdgeInsets.only(left: 40),
      padding: EdgeInsets.only(top: 15.0, right: 15.0),
      child: GestureDetector(
          onTap: () => _debounce(() {
                _biologin();
              }),
          child: showFingerPrint && showFaceId
              ? Image.asset(
                  'assets/images/icon_face_id_ios.png',
                )
              : !showFingerPrint && showFaceId
                  ? Image.asset(
                      'assets/images/icon_face_id_ios.png',
                    )
                  : Icon(
                      Icons.fingerprint,
                      color: Colors.black,
                      size: 37,
                    )),
    );
  }

  void _setDefaults() {
    Settings.rememberMe = false;
    Settings.enableLocalAuth = false;
    Settings.setenableLocalAuth = false;
  }

  Widget _buildForm() {
    return Form(
      // ignore: deprecated_member_use
      // autovalidate: _autoValidate,

      autovalidateMode: _autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomInput(
            textkey: _usernameKey,
            label: 'Username',
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            isEmail: true,
            isSearch: false,
            onTextchanged: (i) {
              isFormValid = _usernameController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty;
              print(Settings.lastUser);
              if (Settings.lastUser.isNotEmpty) {
                if (_usernameController.text !=
                    jsonDecode(Settings.lastUser)['email']) _setDefaults();
              }
              setState(() {});
            },
          ),
          SizedBox(height: 15.0),
          Stack(
            children: [
              Align(
                child: CustomInput(
                  textkey: _passwordKey,
                  isSearch: false,
                  obScurePassword: true,
                  label: 'Password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  isRequired: true,
                  textInputAction: TextInputAction.done,
                  unfocus: true,
                  submitForm: () => _login(),
                  showSuffix: showSuffix,
                  onTextchanged: (i) => setState(() => isFormValid =
                      _usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty),
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Settings.enableLocalAuth
                      ? _bioButton()
                      : SizedBox.shrink())
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
          child: Text("Create an Account",
              style: AppTextStyles.regularText14
                  .copyWith(color: AppColors.lightBlue4)),
          onTap: () {
            Navigator.push(
              context,
              SlideRightRoute(page: CreateAccountScreen()),
            );
          },
        ),
        Row(
          children: <Widget>[
            Text('Remember Me',
                style: AppTextStyles.regularText14
                    .copyWith(color: AppColors.lightBlue4)),
            CustomToggle(
              hasText: false,
              onChange: (value) => setState(() => Settings.rememberMe = value),
              value: _remeberMe,
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
              style: AppTextStyles.regularText15,
            ),
          ),
        if (verificationSent)
          Text(
            verificationSendMessage,
            style: AppTextStyles.regularText15,
          ),
        SizedBox(height: 5),
        BsRaisedButton(
          onPressed: _login,
          disabled: !isFormValid,
        ),
        SizedBox(height: 24),
        GestureDetector(
            child: Text(
              "Forgot my Password",
              style: AppTextStyles.regularText15,
            ),
            onTap: () {
              Navigator.push(context, SlideRightRoute(page: ForgetPassword()));
            }),
      ],
    );
  }
}
