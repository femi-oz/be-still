import 'package:be_still/enums/error_type.dart';
import 'package:be_still/utils/settings.dart';

class StringUtils {
  static String enumName(String enumToString) {
    List<String> paths = enumToString.split(".");
    return paths[paths.length - 1];
  }

  static const String errorOccured = 'An error occured.';
  static const String reloginErrorOccured =
      'You have to be recently logged in the perform this action. Please re-login';
  static String backgroundImage = 'assets/images/bestill_arrows-bg-lt.png';

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
      "Be Still is a ministry of Second Baptist Church Houston, TX";

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case ErrorType.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please login or reset your password.";
        break;
      case ErrorType.invalidEmail:
        errorMessage = "Email format is wrong";
        break;
      case ErrorType.wrongPassword:
        errorMessage = "Username / Password is incorrect";
        break;
      case ErrorType.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case ErrorType.networkRequestFailed:
        errorMessage = "Please check your internet connection and try again";
        break;
      case ErrorType.requiresRecentLogin:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case ErrorType.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case ErrorType.unavailable:
        errorMessage =
            "The service is currently unavailable. Please try again later";
        break;
      case ErrorType.userNotVerified:
        errorMessage =
            "You email address has not been verified. Please verify and try again";
        break;
      default:
        errorMessage = "The application has encountered an error.";
    }

    return errorMessage;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
