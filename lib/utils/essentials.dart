import 'package:flutter/material.dart';

class AppColors {
  static List<Color> getBackgroudColor(bool isDarkMode) {
    List<Color> retVal;
    switch (isDarkMode) {
      case true:
        retVal = [const Color(0xFF021D3C), const Color(0xFF073668)];
        break;
      case false:
        retVal = [const Color(0xFFCED1D4), const Color(0xFFFAFBFB)];
        break;
      default:
        retVal = [const Color(0xFFCED1D4), const Color(0xFFFAFBFB)];

        break;
    }
    return retVal;
  }

  static List<Color> getDetailBgColor(bool isDarkMode) {
    List<Color> retVal;
    switch (isDarkMode) {
      case true:
        retVal = [const Color(0xFF012B4C), const Color(0xFF033565)];
        break;
      case false:
        retVal = [const Color(0xFFf0f4fa), const Color(0xFFE6E9ED)];
        break;
      default:
        retVal = [const Color(0xFFf0f4fa), const Color(0xFFE6E9ED)];

        break;
    }
    return retVal;
  }

  static Color getTextFieldBgColor(bool isDarkMode) {
    Color retVal;
    switch (isDarkMode) {
      case true:
        retVal = const Color(0xFF022F52).withOpacity(0.4);
        break;
      case false:
        retVal = const Color(0xFFFFFFFF).withOpacity(0.5);
        break;
      default:
        retVal = const Color(0xFFFFFFFF).withOpacity(0.5);
        break;
    }
    return retVal;
  }

  static Color getAppBarColor(bool isDarkMode) {
    Color retVal;
    switch (isDarkMode) {
      case true:
        retVal = const Color(0xFF002D4B);
        break;
      case false:
        retVal = const Color(0xFF005780);
        break;
      default:
        retVal = const Color(0xFF005780);

        break;
    }
    return retVal;
  }

  static Color getPrayerMenuColor(bool isDarkMode) {
    Color retVal;
    switch (isDarkMode) {
      case true:
        retVal = const Color(0xFF005780);
        break;
      case false:
        retVal = const Color(0xFFFFFFFF);
        break;
      default:
        retVal = const Color(0xFFFFFFFF);

        break;
    }
    return retVal;
  }

  static Color getPrayerCardBgColor(bool isDarkMode) {
    Color retVal;
    switch (isDarkMode) {
      case true:
        retVal = const Color(0xFF012B4D);
        break;
      case false:
        retVal = const Color(0xFFFFFFFF);
        break;
      default:
        retVal = const Color(0xFFFFFFFF);

        break;
    }
    return retVal;
  }

  static const List<Color> customLogoShaperadient = [
    const Color(0xFF005177),
    const Color(0xFF001B42),
  ];
  static const Color shadowColor = const Color(0xFF001439);
  static const Color offWhite4 = const Color(0xFFF1F5F9);

  static const Color lightBlue1 = const Color(0xFF005882);
  static const Color lightBlue2 = const Color(0xFF009DCE);
  static const Color lightBlue3 = const Color(0xFF00ACD8);
  static const Color lightBlue4 = const Color(0xFF009FD0);

  static const Color grey = const Color(0xFF51575C);
  static const Color red = const Color(0xFFbf0606);
  static const Color darkBlue = const Color(0xFF1B3A5E);
  static const Color darkBlue2 = const Color(0xFF015380);

  // static const Color offWhite5 = const Color(0xFF005780);
  // static const Color blueGrey = const Color(0xFF51575C);

  // static const Color lightBlue = const Color(0xFF4BC2FF);
  // static const Color blue = const Color(0xFF2088FC);
  // static const Color blueAccent = const Color(0xFF2E84F8);

  // static const Color capriBlue = const Color(0xFF4BC2FF);
  // static const Color turquiose = const Color(0xFF50DFD7);

  // static const Color purple = const Color(0xFFAC5BF7);

  // static const Color yellow = const Color(0xFFFFCE0B);
}

class AppTextStyles {
  static const TextStyle regularText11 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText13 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText14 = const TextStyle(
    color: AppColors.offWhite4,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText16 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText16b = const TextStyle(
    height: 1.44,
    color: AppColors.offWhite4,
    fontSize: 16,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText18b = const TextStyle(
    height: 1.44,
    color: AppColors.offWhite4,
    fontSize: 18,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText22 = const TextStyle(
    height: 1.44,
    color: AppColors.offWhite4,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText20 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText24 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle errorText = const TextStyle(
    color: AppColors.red,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle titleWhite = const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle headline4White = const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static const TextStyle headline6Grey = const TextStyle(
    color: AppColors.grey,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.2,
  );

  static const TextStyle modalTitle = const TextStyle(
    color: AppColors.darkBlue,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static const TextStyle listTitle = const TextStyle(
    color: AppColors.grey,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );

  static const TextStyle normalDarkBlue = const TextStyle(
    color: AppColors.darkBlue,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 1,
  );
}
