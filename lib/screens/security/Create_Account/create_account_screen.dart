import 'dart:convert';

import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/security/Create_Account/Widgets/success.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  // bool disabled = false;

  TextEditingController _firstnameController = new TextEditingController();
  TextEditingController _lastnameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  DateTime _selectedDate;
  bool _enableSubmit = false;
  bool _autoValidate = false;

  var termsAccepted = false;

  _selectDob() async {
    FocusScope.of(context).unfocus();
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
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

  _agreeTerms(bool value) {
    setState(() => _enableSubmit = value);
  }

  void _createAccount() async {
    if (!_enableSubmit) {
      PlatformException e = PlatformException(
          code: 'custom',
          message: 'You must accept terms to create an account.');
      BeStilDialog.showErrorDialog(context, e, null, null);
      return;
    }
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();

    try {
      await BeStilDialog.showLoading(context, 'Registering...');
      if (_firstnameController.text == null ||
          _firstnameController.text.trim() == '') {
        BeStilDialog.hideLoading(context);
        BeStillSnackbar.showInSnackBar(
            message: 'First Name is empty, please enter a valid name.',
            key: _scaffoldKey);
      } else if (_lastnameController.text == null ||
          _lastnameController.text.trim() == '') {
        BeStilDialog.hideLoading(context);
        BeStillSnackbar.showInSnackBar(
            message: 'Last Name is empty, please enter a valid name.',
            key: _scaffoldKey);
      } else {
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .registerUser(
          password: _passwordController.text,
          email: _emailController.text,
          firstName: _firstnameController.text,
          lastName: _lastnameController.text,
          dob: _selectedDate,
        );
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser(false);
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        Settings.lastUser =
            Settings.rememberMe ? jsonEncode(user.toJson2()) : '';
        Settings.userPassword =
            Settings.rememberMe ? _passwordController.text : '';
        BeStilDialog.hideLoading(context);
        // await Provider.of<NotificationProvider>(context, listen: false)
        //     .setDevice(user.id);
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: CreateAccountSuccess()),
          (Route<dynamic> route) => false,
        );
      }
    } on HttpException catch (e, s) {
      var message = '';

      if (e.message ==
          'The email has already been registered. Please login or reset your password.') {
        message =
            'That email address is already in use. Please select another one.';
      } else {
        message = e.message;
      }

      BeStilDialog.hideLoading(context);

      PlatformException er =
          PlatformException(code: 'custom', message: message);

      BeStilDialog.showErrorDialog(context, er, null, s);
    } catch (e, s) {
      Provider.of<LogProvider>(context, listen: false).setErrorLog(e.toString(),
          _emailController.text, 'REGISTER/screen/_createAccount');

      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(context, e, null, s);
      // }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    // disabled = Provider.of<MiscProvider>(context).disable;
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
                              // SizedBox(height: 100),
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
                  // Settings.rememberMe
                  //     ? Provider.of<MiscProvider>(context, listen: false)
                  //         .setVisibility(false)
                  //     : Provider.of<MiscProvider>(context, listen: false)
                  //         .setVisibility(true);
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
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
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        autovalidate: _autoValidate,
        child: Column(
          children: <Widget>[
            CustomInput(
              label: 'First Name',
              controller: _firstnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              label: 'Last Name',
              controller: _lastnameController,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
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
                    label: 'Date of Birth (optional)',
                    controller: _dobController,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            CustomInput(
              isPassword: true,
              obScurePassword: true,
              label: 'Password',
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
            ),
            SizedBox(height: 15.0),
            CustomInput(
              obScurePassword: true,
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              isRequired: true,
              validator: (value) {
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
                      'Read the Terms of Use',
                      style: AppTextStyles.regularText15,
                    ),
                  ),
                  onTap: () => _createTermsDialog(context),
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Theme(
                      data: ThemeData(
                          unselectedWidgetColor: AppColors.lightBlue3),
                      child: Switch.adaptive(
                        value: termsAccepted,
                        activeColor: AppColors.lightBlue4,
                        onChanged: (val) {
                          setState(() {
                            _agreeTerms(val);
                            termsAccepted = val;
                          });
                        },
                      ),
                    ),
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

  _createTermsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.dialogGradient,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        AppIcons.bestill_close,
                        color: AppColors.dialogClose,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('TERMS OF USE', style: AppTextStyles.boldText24),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      child: Text(
                        "Welcome to the Be Still App. We provide services to you subject to the following terms. If you download / use the Be Still App, you accept these terms. Please read them carefully.",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "ELECTRONIC COMMUNICATIONS",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "When you use the Be Still app or send emails to us, you are communicating with Be Still App / Second Baptist Church electronically. You consent to receive communications from us electronically. We will communicate with you by email or by posting notices on the app. You agree that all agreements, notices, disclosures and other communications that we provide to you electronically satisfy any legal requirement that such communications be in writing.",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "COPYRIGHT, LICENSE AND SITE ACCESS",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      child: Text(
                        "All content included in this app or on the related websites, such as text, graphics, logos, button icons, images, audio clips, digital downloads, data compilations, and software, is the property of the Second Baptist Church or its content suppliers and protected by United States and international copyright laws. The compilation of all content in this app and related websites is the exclusive property of Second Baptist Church and protected by U.S. and international copyright laws. All software used in this app is the property of the Second Baptist Church or its software suppliers and protected by United States and international copyright laws. This app or any portion of this app may not be reproduced, duplicated, copied, sold, resold, or otherwise exploited for any commercial purpose without express written consent of Second Baptist Church. You may not frame or utilize framing techniques to enclose any trademark, logo, or other proprietary information (including images, text, page layout, or form) of Be Still App. You may not use any meta tags or any other \"hidden text\" utilizing Be Still App or Second Baptist's name or trademarks without the express written consent of Second Baptist Church. Any unauthorized use terminates the permission or license granted by Second Baptist Church. You are granted a limited, revocable, and nonexclusive right to create a hyperlink to the app login page so long as the link does not portray Be Still App / Second Baptist Church in a false, misleading, derogatory, or otherwise offensive matter. You may not use any Be Still App / Second Baptist Church logo or other proprietary graphic or trademark as part of the link without express written permission. You may not use Be Still App / Second Baptist Church logo on any third party website.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "YOUR ACCOUNT",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "If you use this site, you are responsible for maintaining the confidentiality of your account and password and for restricting access to your phone, and you agree to accept responsibility for all activities that occur under your account or password. If you are under 18, you may use Be Still App only with involvement of a parent or guardian. Second Baptist Church reserves the right to refuse service, terminate accounts, remove or edit content at their sole discretion.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "PRAYER REQUESTS, COMMUNICATIONS, AND OTHER CONTENT",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "App users may post prayer requests and other communications so long as the content is not illegal, obscene, threatening, defamatory, invasive of privacy, infringing of intellectual property rights, or otherwise injurious to third parties or objectionable and does not consist of or contain software viruses, political campaigning, commercial solicitation, chain letters, mass mailings, or any form of \"spam.\" You may not use a false email address, impersonate any person or entity, or otherwise mislead as to the origin of a prayer request or other content. Second Baptist Church reserves the right (but not the obligation) to remove or edit such content at its sole discretion.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "PRAYER GROUPS",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "Every Be Still App user has the ability to create and/or join groups to share prayer requests and to pray for others. Second Baptist Church reserves the right at any time, at its sole discretion, to remove a prayer group or any part of its content. By creating a login and using the Be Still App, you agree not to use the app or any personal information contained within for any solicitations including but not limited to solicitations of one's personal business or employer, solicitations for personal financial assistance or assistance on behalf of another, and solicitations for mission activities not sponsored by Second Baptist Church. You also agree to not publish any information that promotes, recommends, or references political candidates or political organizations. By using the Be Still App, you agree not to create fictitious prayer requests intended to defraud, harass, or confuse other users. By using the Be Still App, you agree that you are solely responsible for obtaining permission before sharing / posting any request or information on someone else’s behalf.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY",
                        style: AppTextStyles.boldText16.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "THIS APP IS PROVIDED BY SECOND BAPTIST CHURCH ON AN \"AS IS\" AND \"AS AVAILABLE\" BASIS. SECOND BAPTIST CHURCH MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, AS TO THE OPERATION OF THIS APP OR THE INFORMATION, CONTENT, MATERIALS, OR PRODUCTS INCLUDED IN THIS APP. YOU EXPRESSLY AGREE THAT YOUR USE OF THIS APP IS AT YOUR SOLE RISK. TO THE FULL EXTENT PERMISSIBLE BY APPLICABLE LAW, SECOND BAPTIST CHURCH DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. SECOND BAPTIST CHURCH DOES NOT WARRANT THAT THIS APP, ITS SERVERS, OR EMAIL SENT FROM SECOND BAPTIST CHURCH ARE FREE OF VIRUSES OR OTHER HARMFUL COMPONENTS. SECOND BAPTIST CHURCH WILL NOT BE LIABLE FOR ANY DAMAGES OF ANY KIND ARISING FROM THE USE OF THIS SITE, INCLUDING, BUT NOT LIMITED TO DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, AND CONSEQUENTIAL DAMAGES. CERTAIN STATE LAWS DO NOT ALLOW LIMITATIONS ON IMPLIED WARRANTIES OR THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES. IF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE DISCLAIMERS, EXCLUSIONS, OR LIMITATIONS MAY NOT APPLY TO YOU, AND YOU MIGHT HAVE ADDITIONAL RIGHTS.",
                        style: AppTextStyles.boldText16.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "APPLICABLE LAW",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "By downloading or using the Be Still App, you agree that the laws of the state of Texas, without regard to principles of conflict of laws, will govern these Terms of Use and any dispute of any sort that might arise between you and Second Baptist Church.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "YOUR CONSENT",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "By downloading or using this app, you are giving Second Baptist Church your express consent to use the information collected about you as this policy outlines.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "QUESTIONS",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "If you have any questions or concerns regarding this policy, please feel free to contact us:",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "Technology Ministry\nSecond Baptist Church\n6400 Woodway\nHouston, TX 77057\nsupport@second.org\n713-465-3408",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PRIVACY POLICY', style: AppTextStyles.boldText24),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      child: Text(
                        "Random things here about how you use the app. What things,. app is willing to be responsible' for, and what things it spouts as being at Me users' own risk. Legal jargon and etc. such Mat it delineates and follows whatever parameters any and all lawyers are happy with to use here as a terms for service with or without a synopsis or conclusion. ",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "The Be Still App is a ministry of Second Baptist Church.  We understand the spiritual benefits of this application and the tremendous ministry opportunities afforded by its use. We also understand the importance of respecting and protecting your privacy.",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "INFORMATION COLLECTED AND HOW IT IS USED",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "The Be Still App collects two types of information when you use the app:",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "1.	Personal InformationThis is information that you voluntarily supply to us through the app when creating an account. We intentionally collect as little personally identifiable information as possible. If you post a prayer request or personal information about another person, it is solely your responsibility to obtain the 3rd party’s permission before posting. All personal information is kept confidential and is not distributed, sold, or shared with anyone. It is strictly used for the purposes of allowing Second Baptist Church to encourage you in your walk with Jesus Christ.",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "2.	Technical InformationThis is information that is exchanged between our computer and your phone when using the app. This information is anonymous and cannot personally identify you. This type of information includes, but is not limited to, your IP address, referring URL, type of phone, and whether you are a first-time visitor or returning visitor to the app. The technical information gathered from those utilizing our app allows us to improve the usability of the app and reduce the number of problems that may occur. If you have questions about the use of personal and technical information collected through our app, you may contact us by email at support@second.org.",
                        style: AppTextStyles.regularText16b.copyWith(
                            color: Settings.isDarkMode
                                ? AppColors.offWhite4
                                : AppColors.grey4),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "COOKIES",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      child: Text(
                        "Cookies are small pieces of information that are stored on the user’s hard drive containing information about the user.  They are used to allow web servers to recognize the computer used to access a web site.  Most computers are set up to automatically receive cookies.  However, you can prevent cookies from being placed on your computer by changing the preferences in your web browser.  Turning off cookies may affect how some of the sites the app links to perform on your device.  Cookies are not used to gain any personal information about you.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "USES OF INFORMATION COLLECTED",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "Any information that Second Baptist Church collects and that you provide is strictly used to extend the ministry of our church. We do not sell, lease, or distribute any information to any commercial entities. The Be Still App may offer services such as sharing prayers, groups, or other open discussion forums. Be aware that any information that you voluntarily share with others such as prayers, groups or other open forums is considered public information and is not protected.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "LINKS",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "This app may contain links to other apps and sites. Second Baptist Church does not endorse or receive any financial benefit from the entities for which links are provided. Links to third party entities and related materials and information are provided only as a ministry. These sites may not be owned or operated by Second Baptist Church and we are not responsible for the privacy policies or information collection practices of these sites. The Privacy Policy of the Be Still App does not apply to such third parties and they are responsible for their own privacy statements. We encourage you to be aware of the privacy statements of each and every app or site that collects personally identifiable information.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "SECURITY",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "The security of the information that you provide is very important to Second Baptist Church. Therefore, Second Baptist Church takes every precaution to protect this information. Be Still App’s data is stored in the Microsoft Azure cloud.  For data at rest, all data written to the Azure storage platform is encrypted through 256-bit AES encryption and is FIPS 140-2 compliant. By default, Microsoft-managed keys protect the data, and the Azure Key Vault helps ensure that encryption keys are properly secured. For data in transit—data moving between user devices and Microsoft datacenters or within and between the datacenters themselves—Microsoft adheres to IEEE 802.1AE MAC Security Standards, and uses and enables the use of industry-standard encrypted transport protocols, such as Transport Layer Security (TLS) and Internet Protocol Security (IPsec). We will attempt to notify you as soon as possible if our security system is breached and data is compromised.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Container(
                      child: Text(
                        "CHILDREN'S PRIVACY",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "We at Second Baptist Church are strongly committed to the safety and protection of children. Second Baptist Church does not knowingly accept or collect personal information (such as name, address, e-mail address, telephone number, social security number, credit card information, date of birth, zip code, and any other information that would allow personal identification) from children under the age of 13 without the prior written verifiable consent from the parent(s) or guardian. Second Baptist Church does not disclose any information collected from children to third parties.",
                        style: AppTextStyles.regularText16b.copyWith(
                          color: Settings.isDarkMode
                              ? AppColors.offWhite4
                              : AppColors.grey4,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
