import 'package:be_still/enums/theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreferenes {
  setThemeMode(String themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', themeMode);
  }

  Future<String> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeMode =
        prefs.getString('themeMode') ?? BThemeMode.light.toString();
    return themeMode;
  }
}
