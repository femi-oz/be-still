import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/notification_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/push_notification.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/bs_raised_button.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../entry_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _isUnderAge = false;

  TextEditingController _firstnameController = new TextEditingController();
  TextEditingController _lastnameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  DateTime _selectedDate;
  bool _enableSubmit = false;

  var termsAccepted = false;

  _selectDob() async {
    FocusScope.of(context).unfocus();
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime.now(),
    );
    _isUnderAge =
        (DateTime(DateTime.now().year, pickedDate.month, pickedDate.day)
                    .isAfter(DateTime.now())
                ? DateTime.now().year - pickedDate.year - 1
                : DateTime.now().year - pickedDate.year) <
            18;

    if (pickedDate == null) {
      return null;
    }
    setState(() {
      _selectedDate = pickedDate;
      _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    });
  }

  _agreeTerms(bool value) {
    setState(() {
      _enableSubmit = value;
    });
  }

  void _createAccount() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();

    try {
      await BeStilDialog.showLoading(context, 'Registering...');
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
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<NotificationProvider>(context, listen: false)
          .init(userId);
      // get all local notifications from db
      await Provider.of<NotificationProvider>(context, listen: false)
          .setLocalNotifications(userId);
      final _localNotifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications;
      //set notification in new device

      // The device's timezone.
      String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

      // Find the 'current location'
      final location = tz.getLocation(timeZoneName);
      //set notification in new device
      for (int i = 0; i < _localNotifications.length; i++) {
        final scheduledDate =
            tz.TZDateTime.from(_localNotifications[i].scheduledDate, location);
        await LocalNotification.configureNotification(
            context, _localNotifications[i].fallbackRoute);
        await LocalNotification.setLocalNotification(
          title: _localNotifications[i].title,
          description: _localNotifications[i].description,
          scheduledDate: scheduledDate,
          payload: _localNotifications[i].payload,
          frequency: _localNotifications[i].frequency,
        );
      }
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushReplacementNamed(EntryScreen.routeName);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(message: e.message, key: _scaffoldKey);
    } catch (e) {
      Provider.of<LogProvider>(context, listen: false).setErrorLog(e.toString(),
          _emailController.text, 'REGISTER/screen/_createAccount');

      BeStilDialog.hideLoading(context);
      BeStillSnackbar.showInSnackBar(
          message: StringUtils.errorOccured, key: _scaffoldKey);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image:
                  AssetImage(StringUtils.backgroundImage(Settings.isDarkMode)),
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
            ],
          ),
        ),
      ),
    );
  }

  _buildFooter() {
    return Column(
      children: <Widget>[
        BsRaisedButton(
            disabled: !_enableSubmit,
            onPressed: () => !_enableSubmit
                ? BeStilDialog.showErrorDialog(
                    context,
                    'You must accept terms to proceed',
                  )
                : _createAccount()),
        SizedBox(height: 16),
        InkWell(
          child: Text(
            StringUtils.backText,
            style: AppTextStyles.regularText13,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
                    label: 'Birthday',
                    controller: _dobController,
                    isRequired: true,
                    validator: (value) {
                      if (_isUnderAge) {
                        return 'You must be 18 or older to use this app';
                      }
                      return null;
                    },
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
              isPassword: true,
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
                      'Read the Terms of Use / User Agreement',
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
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, right: 6.0),
                        child: IconButton(
                          icon: Icon(
                            AppIcons.bestill_close,
                            color: AppColors.dialogClose,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  Text('Terms of Use', style: AppTextStyles.boldText24),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
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
                            "SOMEWHERE IN HERE THERE WILL BE TEXT THAT IS ALL CAPS FOR NO REASON OTHER THAN LAWYER PEOPLE LOVE SHOUTING CERTAIN THINGS WHEN PUTTING THEM DOWN ON PAPER/DOCUMENT. ",
                            style: AppTextStyles.regularText16b.copyWith(
                                color: Settings.isDarkMode
                                    ? AppColors.offWhite4
                                    : AppColors.grey4),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Container(
                          child: Text(
                            "Also, you have. make the terms and verbiage of the terms extremely long,. who in Me legal world would ever say that something that should be legally binding could be short, concise, and easy to understand by Me regular Joe being as-that's who is normally going to be legally bound by said legal verbiage. ",
                            style: AppTextStyles.regularText16b.copyWith(
                                color: Settings.isDarkMode
                                    ? AppColors.offWhite4
                                    : AppColors.grey4),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Container(
                          child: Text(
                            "If you have gotten this far in reading -.i.e., I hope you've really enjoyed (or under.00d) the level of dry-sarcasm involved in the voicing these particular views. Phase, feel free to acknowledge your own opinion, however you should be fonmamed [hag it differs from my own view in anyway, I may dismiss it as irrelevant and misguided. ",
                            style: AppTextStyles.regularText16b.copyWith(
                                color: Settings.isDarkMode
                                    ? AppColors.offWhite4
                                    : AppColors.grey4),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
