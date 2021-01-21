import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAccountSuccess extends StatefulWidget {
  static const routeName = 'create-account-success';

  @override
  _CreateAccountSuccessState createState() => _CreateAccountSuccessState();
}

class _CreateAccountSuccessState extends State<CreateAccountSuccess> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 10000),
        () => Navigator.of(context).pushReplacementNamed(EntryScreen.routeName),
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
            colors: AppColors.backgroundColor,
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
              'Your account has been succesfully created.',
              style: TextStyle(
                color: AppColors.textFieldText,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
            Text(
              'Login to your BeStill...',
              style: TextStyle(
                color: AppColors.textFieldText,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
