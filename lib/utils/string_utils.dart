import 'package:be_still/utils/settings.dart';

class StringUtils {
  static String enumName(String enumToString) {
    List<String> paths = enumToString.split(".");
    return paths[paths.length - 1];
  }

  static const String errorOccured = 'An error occured.';
  static const String reloginErrorOccured =
      'You have to be recently logged in the perform this action. Please re-login';
  static String backgroundImage([bool isDarkMode]) {
    String retVal;
    switch (Settings.isDarkMode) {
      case true:
        retVal = 'assets/images/background-pattern-dark.png';
        break;
      case false:
        retVal = 'assets/images/bestill_arrows-bg-lt.png';
        break;
      default:
        retVal = 'assets/images/bestill_arrows-bg-lt.png';

        break;
    }
    return retVal;
  }

  static String drawerBackgroundImage([bool isDarkMode]) {
    String retVal;
    switch (Settings.isDarkMode) {
      case true:
        retVal = 'assets/images/bestill_menu-logo-drk.png';
        break;
      case false:
        retVal = 'assets/images/bestill_menu-logo-lt.png';
        break;
      default:
        retVal = 'assets/images/bestill_menu-logo-lt.png';

        break;
    }
    return retVal;
  }

  static String year = DateTime.now().year.toString();
  static String logo = 'assets/images/bestil_main_logo.png';
  static String backText = "Go Back";
  static String copyRight1 = '$year All Rights Reserved';
  static String copyRight2 =
      "BeStill is a ministry of Second Baptist Church Houston, TX";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
