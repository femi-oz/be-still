import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';

Color dynamicColor({
  @required int light,
  @required int dark,
}) {
  Color retVal;
  switch (Settings.isDarkMode) {
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
  @required int light,
  @required int dark,
  @required int light2,
  @required int dark2,
}) {
  List<Color> retVal;
  switch (Settings.isDarkMode) {
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
  static List<Color> get backgroundColor => dynamicGradientColor(
      light: 0xFFEDEFF0,
      light2: 0xFFEDEFF0,
      dark: 0xFF01162E,
      dark2: 0xFF043569);
  static List<Color> get prayerMenu => dynamicGradientColor(
      light: 0xFF00438D,
      light2: 0xFF009CCE,
      dark: 0xFF014A70,
      dark2: 0xFF013053);
  static List<Color> get appBarBackground => dynamicGradientColor(
      light: 0xFF003B87,
      light2: 0xFF009FD0,
      dark: 0xFF0D1319,
      dark2: 0xFF0D1319);
  static List<Color> get bottomNavigationBackground => dynamicGradientColor(
      light: 0xFF003B87,
      light2: 0xFF009FD0,
      dark: 0xFF0D1319,
      dark2: 0xFF0D1319);

  static Color get inactvePrayerMenu =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF005780);

  static Color get textFieldBackgroundColor =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF022F52);
  static Color get appBarTextColor =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF005780);
  static Color get appBarIconColor =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF005780);
  static Color get logoutTextColor =>
      dynamicColor(light: 0xFF003B87, dark: 0xFF002D4B);
  static Color get prayerPrimaryColor => dynamicColor(
        light: 0xFF5EC2E1,
        dark: 0xFF014E75,
      );

  static Color get detailBackgroundColor =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF023157);
  static Color get detailTopTextColor =>
      dynamicColor(light: 0xFF009FD0, dark: 0xFF009FD0);
  static Color get prayerMenuColor => dynamicColor(
        light: 0xFFFFFFFF,
        dark: 0xFF005780,
      );
  static Color get prayerCardBgColor => dynamicColor(
        light: 0xFFFFFFFF,
        dark: 0xFF009fd0,
      );
  static Color get dropShadow => dynamicColor(
        light: 0xFFBBBDBF,
        dark: 0xFF011D3D,
      );
  static Color get activeButton => dynamicColor(
        light: 0xFF9BD4E5,
        dark: 0xFF005780,
      );
  static Color get cardBorder => dynamicColor(
        light: 0xFFFFFFFF,
        dark: 0xFF005780,
      );
  static Color get prayerCardTextColor => dynamicColor(
        light: 0xFF788489,
        dark: 0xFFC1C5C8,
      );
  static Color get prayerCardUserColor => dynamicColor(
        light: 0xFF003B87,
        dark: 0xFF00ACD8,
      );
  static Color get divider => dynamicColor(
        light: 0xFF003B87,
        dark: 0xFF005780,
      );
  static Color get textFieldText => dynamicColor(
        light: 0xFF79858A,
        dark: 0xFFC1C5C8,
      );
  static Color get textFieldBorder => dynamicColor(
        light: 0xFFB4E3F1,
        dark: 0xFF014C73,
      );
  static Color get prayeModeBg => dynamicColor(
        light: 0xFFE6E9ED,
        dark: 0xFF101820,
      );
  static Color get prayeModeBorder => dynamicColor(
        light: 0xFF0C3A4C,
        dark: 0xFF0C3A4C,
      );
  static Color get splashTextColor => dynamicColor(
        light: 0xFF005780,
        dark: 0xFF00ACD8,
      );
  static Color get bottomNavIconColor => dynamicColor(
        light: 0xFF005780,
        dark: 0xFFFFFFFF,
      );
  static Color get drawerTopColor => dynamicColor(
        light: 0xFFFFFFFF,
        dark: 0XFF0D1319,
      );

  static const List<Color> customLogoShaperadient = [
    const Color(0xFF005177),
    const Color(0xFF001B42),
  ];
  static const Color shadowColor = const Color(0xFF001439);
  static const Color appbarColor = const Color(0xFF0D1319);

  static const Color offWhite1 = const Color(0xFF788489);
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
  static const Color grey4 = const Color(0xFFC1C5C8);

  static const Color red = const Color(0xFFbf0606);

  static const Color darkBlue = const Color(0xFF1B3A5E);
  static const Color darkBlue2 = const Color(0xFF015380);
  static const Color darkBlue3 = const Color(0xFF31373D);
  static const Color darkBlue4 = const Color(0xFF043569);

  static const Color menuColor = const Color(0xFF009FD0);
  static const Color nameRecogntionColor = const Color(0xFF0D1319);

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
  // new fonts region
  // medium => w400, demi => w500, bold => w700, regular=> w300
  static TextStyle get mediumText10 => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText12 => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );

  // end region

  static TextStyle get regularText11 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 11,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText13 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 13,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText14 => const TextStyle(
        color: AppColors.offWhite4,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText15 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText15b => const TextStyle(
        color: AppColors.offWhite4,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText16b => const TextStyle(
        height: 1.44,
        color: AppColors.offWhite4,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText18b => const TextStyle(
        height: 1.44,
        color: AppColors.offWhite4,
        fontSize: 18,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText20 => const TextStyle(
        height: 1.44,
        color: AppColors.lightBlue4,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText22 => const TextStyle(
        height: 1.44,
        color: AppColors.offWhite4,
        fontSize: 22,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText24 => const TextStyle(
        height: 1.44,
        color: AppColors.offWhite4,
        fontSize: 24,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );
  static TextStyle get regularText26 => const TextStyle(
        height: 1.44,
        color: AppColors.offWhite4,
        fontSize: 26,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      );

  static TextStyle get demiBoldText34 => const TextStyle(
        height: 1.44,
        color: AppColors.grey4,
        fontSize: 34,
        fontWeight: FontWeight.w500,
        letterSpacing: 3.5,
      );
  static TextStyle get boldText9 => const TextStyle(
        color: AppColors.lightBlue1,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText12 => const TextStyle(
        color: AppColors.lightBlue1,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText14 => const TextStyle(
        color: AppColors.lightBlue1,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText16 => const TextStyle(
        color: AppColors.lightBlue1,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText18 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText20 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText24 => const TextStyle(
        color: AppColors.lightBlue4,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText28 => const TextStyle(
        color: AppColors.grey3,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get boldText30 => const TextStyle(
        color: AppColors.grey3,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
  static TextStyle get errorText => const TextStyle(
        color: AppColors.red,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  // static TextStyle get titleWhite => const TextStyle(
  //       color: Colors.white,
  //       fontSize: 18,
  //       fontWeight: FontWeight.bold,
  //       letterSpacing: 0.5,
  //     );

  // static TextStyle get headline4White => const TextStyle(
  //       color: Colors.white,
  //       fontSize: 18,
  //       fontWeight: FontWeight.bold,
  //       letterSpacing: 1.5,
  //     );

  // static TextStyle get headline6Grey => const TextStyle(
  //       color: AppColors.grey,
  //       fontSize: 14,
  //       fontWeight: FontWeight.normal,
  //       letterSpacing: 1.2,
  //     );

  // static TextStyle get modalTitle => const TextStyle(
  //       color: AppColors.darkBlue,
  //       fontSize: 18,
  //       fontWeight: FontWeight.w700,
  //       letterSpacing: 1,
  //     );

  // static TextStyle get listTitle => const TextStyle(
  //       color: AppColors.grey,
  //       fontSize: 14,
  //       fontWeight: FontWeight.bold,
  //       letterSpacing: 1.1,
  //     );

  // static TextStyle get normalDarkBlue => const TextStyle(
  //       color: AppColors.darkBlue,
  //       fontSize: 16,
  //       fontWeight: FontWeight.normal,
  //       letterSpacing: 1,
  //     );

  static TextStyle get drawerMenu => const TextStyle(
        color: AppColors.menuColor,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
}
