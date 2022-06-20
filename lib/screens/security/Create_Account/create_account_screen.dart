import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/widgets/terms_and_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _firstnameController = new TextEditingController();
  TextEditingController _lastnameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _enableSubmit = false;
  bool _autoValidate = false;

  var termsAccepted = false;

  final key = GlobalKey<FormFieldState>();
  final key2 = GlobalKey<FormFieldState>();
  final key3 = GlobalKey<FormFieldState>();
  final key4 = GlobalKey<FormFieldState>();
  final key5 = GlobalKey<FormFieldState>();
  final key6 = GlobalKey<FormFieldState>();

  _selectDob() async {
    FocusScope.of(context).unfocus();
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) {
      return null;
    }
    setState(() {
      _selectedDate = pickedDate;
      _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    });
  }

  _launchPrivacyURL() async {
    try {
      if (await canLaunch('https://bestillapp.com/privacy-policy/')) {
        await launch('https://bestillapp.com/privacy-policy/');
      } else {
        throw 'Could not launch https://bestillapp.com/privacy-policy/';
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), null, s);
    }
  }

  _launchTermsURL() async {
    try {
      if (await canLaunch('https://bestillapp.com/terms-of-use/')) {
        await launch('https://bestillapp.com/terms-of-use/');
      } else {
        throw 'Could not launch https://bestillapp.com/terms-of-use/';
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), null, s);
    }
  }

  _agreeTerms(bool value) {
    setState(() => _enableSubmit = value);
  }

  void _createAccount() async {
    if (!_enableSubmit) {
      PlatformException e = PlatformException(
          code: 'custom',
          message: 'You must accept terms to create an account.');
      final s = StackTrace.fromString(e.stacktrace ?? '');
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
      return;
    }
    setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return null;
    _formKey.currentState!.save();

    try {
      BeStilDialog.showLoading(context, 'Registering...');
      if (_firstnameController.text.trim().isEmpty) {
        BeStilDialog.hideLoading(context);
        PlatformException e = PlatformException(
            code: 'custom',
            message: 'First Name is empty, please enter a valid name.');
        final s = StackTrace.fromString(e.stacktrace ?? '');
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), UserDataModel(), s);
      } else if (_lastnameController.text.trim().isEmpty) {
        BeStilDialog.hideLoading(context);
        PlatformException e = PlatformException(
            code: 'custom',
            message: 'Last Name is empty, please enter a valid name.');
        final s = StackTrace.fromString(e.stacktrace ?? '');
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), UserDataModel(), s);
      } else {
        await Provider.of<AuthenticationProviderV2>(context, listen: false)
            .registerUser(
          password: _passwordController.text,
          email: _emailController.text,
          firstName: _firstnameController.text,
          lastName: _lastnameController.text,
          dob: _selectedDate,
        );

        Settings.lastUser = '';
        Settings.userPassword = '';
        Settings.enableLocalAuth = false;
        BeStilDialog.hideLoading(context);
        showInfoDialog(context);
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
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
              'Your account registration has been initiated. \n\n Click the link provided in the email sent to you to complete the registration.',
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
                      Navigator.of(context).pushReplacement(
                        SlideRightRoute(
                          page: LoginScreen(),
                        ),
                      );
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
          ),
          height: double.infinity,
          child: Stack(
            children: [
              Align(alignment: Alignment.topCenter, child: CustomLogoShape()),
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(StringUtils.backgroundImage),
                        alignment: Alignment.bottomCenter,
                        fit: BoxFit.cover,
                        colorFilter: new ColorFilter.mode(
                            AppColors.backgroundColor[0].withOpacity(0.2),
                            BlendMode.dstATop),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 260),
                        Text(
                          'CREATE AN ACCOUNT',
                          style: AppTextStyles.boldText24.copyWith(
                              color: Settings.isDarkMode
                                  ? AppColors.lightBlue3
                                  : AppColors.grey2),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Container(
                                  child: _buildForm(),
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.lightBlue3),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero),
                  elevation: MaterialStateProperty.all<double>(0.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.grey),
                  margin: const EdgeInsets.all(0),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  child: Text('Cancel',
                      style: AppTextStyles.regularText16b
                          .copyWith(color: AppColors.white)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero),
                  elevation: MaterialStateProperty.all<double>(0.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !_enableSubmit
                        ? AppColors.lightBlue4.withOpacity(0.5)
                        : AppColors.lightBlue4,
                  ),
                  margin: const EdgeInsets.all(0),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  child: Text('Create',
                      style: !_enableSubmit
                          ? AppTextStyles.regularText16b
                              .copyWith(color: AppColors.white)
                          : AppTextStyles.regularText16b
                              .copyWith(color: AppColors.white)),
                ),
                onPressed: () {
                  _createAccount();
                },
              ),
            )
          ],
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        // ignore: deprecated_member_use
        // autovalidate: _autoValidate,

        autovalidateMode: _autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: <Widget>[
            CustomInput(
              textkey: key,
              label: 'First Name',
              controller: _firstnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              textkey: key2,
              label: 'Last Name',
              controller: _lastnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              textkey: key3,
              label: 'Email',
              isEmail: true,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            GestureDetector(
              onTap: () => _selectDob(),
              child: Container(
                color: Colors.transparent,
                child: IgnorePointer(
                  child: CustomInput(
                    textkey: key4,
                    label: 'Date of Birth (optional)',
                    controller: _dobController,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            CustomInput(
              textkey: key5,
              isPassword: true,
              obScurePassword: true,
              label: 'Password',
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              textkey: key6,
              obScurePassword: true,
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
              validator: (String value) {
                if (_passwordController.text != value) {
                  return 'Password fields do not match';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              unfocus: true,
            ),
            SizedBox(height: 30.0),
            Column(
              children: <Widget>[
                InkWell(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'Read the Privacy Policy',
                        style: AppTextStyles.regularText15,
                      ),
                    ),
                    onTap: () => _launchPrivacyURL()),
                SizedBox(height: 15),
                InkWell(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'Read the Terms of Use',
                        style: AppTextStyles.regularText15,
                      ),
                    ),
                    onTap: () => _launchTermsURL()),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    CustomToggle(
                        hasText: false,
                        onChange: (val) {
                          setState(() {
                            _agreeTerms(val);
                            termsAccepted = val;
                          });
                        },
                        value: termsAccepted),
                    SizedBox(width: 12),
                    Text(
                      'I agree to Terms of Use',
                      style: AppTextStyles.regularText15,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
