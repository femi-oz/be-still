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
  static String quickTipWelcome =
      "Here\'s a quick tour that will get you started.\n\nThe Be Still app can organize all your prayers and lead you through your own personal prayer time.\n\nYou can add prayers to your prayer list, add updates, mark prayers as answered, and access online Bibles and devotionals.\n\nTap ";
  static String quickTipWelcome2 =
      " to begin the tour, or close this window to begin using Be Still right away.";
  static String quickTipList =
      " at any time to view all the prayers in your current prayer list.";
  static String quickTipQuickAccess =
      "You can swipe right or left on any prayer in your prayer list to display common actions.";
  static String quickTipFilters =
      " to toggle between prayer statuses on your list.";
  static String quickTipAdd =
      " to create a new prayer and add it to your prayer list.";
  static String quickTipPray =
      "Tap the Be Still logo to view your prayers one at a time in a distraction-free zone during your prayer time.";
  static String quickTipMore =
      " icon to access recommended online Bibles, learn more about the app in the help section, or log out.";
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
