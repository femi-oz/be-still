import 'package:flutter/material.dart';

Color dynamicColor({
  @required bool isDarkMode,
  @required int light,
  @required int dark,
}) {
  Color retVal;
  switch (isDarkMode) {
    case true:
      retVal = Color(dark);
      break;
    case false:
      retVal = Color(light);
      break;
    default:
      retVal = Color(light);

      break;
  }
  return retVal;
}

List<Color> dynamicGradientColor({
  @required bool isDarkMode,
  @required int light,
  @required int dark,
  @required int light2,
  @required int dark2,
}) {
  List<Color> retVal;
  switch (isDarkMode) {
    case true:
      retVal = [Color(dark), Color(dark2)];
      break;
    case false:
      retVal = [Color(light), Color(light2)];
      break;
    default:
      retVal = [Color(light), Color(light2)];

      break;
  }
  return retVal;
}

class AppColors {
  static List<Color> getBackgroudColor(bool isDarkMode) => dynamicGradientColor(
      isDarkMode: isDarkMode,
      light: 0xFFCED1D4,
      light2: 0xFFFAFBFB,
      dark: 0xFF021D3C,
      dark2: 0xFF073668);
  static List<Color> getDetailBgColor(bool isDarkMode) => dynamicGradientColor(
      isDarkMode: isDarkMode,
      light: 0xFFF0F4Fa,
      light2: 0xFFE6E9ED,
      dark: 0xFF012B4C,
      dark2: 0xFF033565);
  static List<Color> getPrayerMenu(bool isDarkMode) => dynamicGradientColor(
      isDarkMode: isDarkMode,
      light: 0xFF00438D,
      light2: 0xFF009CCE,
      dark: 0xFF014A70,
      dark2: 0xFF013053);

  static Color getInactvePrayerMenu(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF005780,
      );
  static Color appBarBg(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF0D1319,
      );
  static Color getTextFieldBgColor(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF022F52,
      );
  static Color getAppBarColor(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF005780,
        dark: 0xFF002D4B,
      );
  static Color getPrayerPrimaryColor(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF5EC2E1,
        dark: 0xFF014E75,
      );
  static Color getPrayerMenuColor(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF005780,
      );
  static Color getPrayerCardBgColor(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF012B4D,
      );
  static Color getDropShadow(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFBBBDBF,
        dark: 0xFF011D3D,
      );
  static Color getActiveBtn(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF9BD4E5,
        dark: 0xFF025584,
      );
  static Color getCardBorder(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFFFFFFF,
        dark: 0xFF004E75,
      );
  static Color getDivider(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF808C90,
        dark: 0xFF00547C,
      );
  static Color getTextFieldText(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF79858A,
        dark: 0xFFC1C5C8,
      );
  static Color getPrayeModeBg(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFFE6E9ED,
        dark: 0xFF101820,
      );
  static Color getPrayeModeBorder(bool isDarkMode) => dynamicColor(
        isDarkMode: isDarkMode,
        light: 0xFF0C3A4C,
        dark: 0xFF0C3A4C,
      );

  static const List<Color> customLogoShaperadient = [
    const Color(0xFF005177),
    const Color(0xFF001B42),
  ];
  static const Color shadowColor = const Color(0xFF001439);

  static const Color offWhite1 = const Color(0xFF005780);
  static const Color offWhite2 = const Color(0xFFC1C5C8);
  static const Color offWhite4 = const Color(0xFFF1F5F9);

  static const Color dimBlue = const Color(0xFF01537B);
  static const Color lightBlue1 = const Color(0xFF005882);
  static const Color lightBlue2 = const Color(0xFF009DCE);
  static const Color lightBlue3 = const Color(0xFF00ACD8);
  static const Color lightBlue4 = const Color(0xFF009FD0);
  static const Color lightBlue5 = const Color(0xFF01486C);
  static const Color lightBlue6 = const Color(0xFF027BA6);

  static const Color grey = const Color(0xFF51575C);
  static const Color grey2 = const Color(0xFF003B87);
  static const Color grey3 = const Color(0xFF004166);

  static const Color red = const Color(0xFFbf0606);

  static const Color darkBlue = const Color(0xFF1B3A5E);
  static const Color darkBlue2 = const Color(0xFF015380);
  static const Color darkBlue3 = const Color(0xFF31373D);

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
