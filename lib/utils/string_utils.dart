class StringUtils {
  static String enumName(String enumToString) {
    List<String> paths = enumToString.split(".");
    return paths[paths.length - 1];
  }

  static const String errorOccured = 'An error occured.';
  static const String reloginErrorOccured = 'An error occured. lease re-login';
  static String getBackgroundImage(bool isDarkMode) {
    String retVal;
    switch (isDarkMode) {
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

  static String logo = 'assets/images/logo.png';
  static String splashLogo = 'assets/images/splash_icon.png';
  static String backText = "Go Back";
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
