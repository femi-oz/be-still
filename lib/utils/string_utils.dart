import 'package:be_still/utils/settings.dart';

class StringUtils {
  static String enumName(String enumToString) {
    List<String> paths = enumToString.split(".");
    return paths[paths.length - 1];
  }

  static const String errorOccured = 'An error occured.';
  static const String reloginErrorOccured =
      'An error occured. Please login again';
  static String getBackgroundImage([bool isDarkMode]) {
    String retVal;
    switch (Settings.isDarkMode) {
      case true:
        retVal = 'assets/images/background-pattern-dark.png';
        break;
      case false:
        retVal = 'assets/images/background-pattern.png';
        break;
      default:
        retVal = 'assets/images/background-pattern.png';

        break;
    }
    return retVal;
  }

  static String logo = 'assets/images/logo1.png';
  static String splashLogo = 'assets/images/splash_logo2.png';
  static String backText = "Go Back";
  static String copyRight1 = "2020 All Rights Reserved";
  static String copyRight2 =
      "BeStill is a ministry of Second Baptist Church Houston, TX";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
