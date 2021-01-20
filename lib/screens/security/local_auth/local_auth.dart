import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

login() {
// Navigator.of(context).pushNamedAndRemoveUntil(
//     PrayerScreen.routeName, (Route<dynamic> route) => false);
}

class LocalAuth extends StatelessWidget {
  static const routeName = 'local-auth';
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.getBackgroundImage(_themeProvider.isDarkModeEnabled)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CustomLogoShape(),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                width: double.infinity,
                child: Column(
                  children: <Widget>[],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
