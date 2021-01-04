import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPasswordSucess extends StatefulWidget {
  static const routeName = 'forgot-password-success';

  @override
  _ForgetPasswordSucessState createState() => _ForgetPasswordSucessState();
}

class _ForgetPasswordSucessState extends State<ForgetPasswordSucess> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 10000),
        () =>
            Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 100),
        width: double.infinity,
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
        child: Column(
          children: <Widget>[
            Text(
              'Your password has been succesfully reset.',
              style: AppTextStyles.regularText15,
            ),
            SizedBox(height: 20),
            Text(
              'Login to your BesStill...',
              style: AppTextStyles.regularText15,
            ),
          ],
        ),
      ),
    );
  }
}
