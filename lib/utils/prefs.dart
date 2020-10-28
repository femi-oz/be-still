import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreferenes {
  addIsDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getIsDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('isDarkMode') ?? false;
    return boolValue;
  }
}
