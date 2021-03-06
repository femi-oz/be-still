import 'package:flutter/material.dart';

Color getColor(bool isDarkMode, {required int light, required int dark}) =>
    Color(isDarkMode ? dark : light);

List<Color> getGradientColor(bool isDarkMode,
        {required int lightStart,
        required int lightEnd,
        required int darkStart,
        required int darkEnd}) =>
    isDarkMode
        ? [Color(darkStart), Color(darkEnd)]
        : [Color(lightStart), Color(lightEnd)];

class AppColors {
  static bool darkMode = false;

  static List<Color> get backgroundColor => getGradientColor(darkMode,
      lightStart: 0xFFEDEFF0,
      lightEnd: 0xFFFAFBFB,
      darkStart: 0xFF021D3C,
      darkEnd: prussianBlue.value);
  static List<Color> get backgroundLogo => getGradientColor(darkMode,
      lightStart: 0xFFFFFFF,
      lightEnd: 0xFFC1C5C8,
      darkStart: 0xFF005075,
      darkEnd: 0xFF001439);
  static List<Color> get detailBackgroundColor => getGradientColor(darkMode,
      lightStart: 0xFFF0F4Fa,
      lightEnd: 0xFFE6E9ED,
      darkStart: 0xFF012B4C,
      darkEnd: 0xFF033565);

  static List<Color> get prayerMenu => getGradientColor(darkMode,
      lightStart: 0xFF00438D,
      lightEnd: 0xFF009CCE,
      darkStart: 0xFF014A70,
      darkEnd: 0xFF013053);
  static List<Color> get appBarBackground => getGradientColor(darkMode,
      lightStart: 0xFF00438d,
      lightEnd: 0xFF0098cb,
      darkStart: 0xFF0D1319,
      darkEnd: 0xFF0D1319);

  static List<Color> get buttonGradient => getGradientColor(darkMode,
      lightStart: 0xFF003C88,
      lightEnd: 0xFF009ED0,
      darkStart: offWhite1.value,
      darkEnd: lightBlue4.value);
  static List<Color> get dialogGradient => getGradientColor(darkMode,
      lightStart: 0xFFEDEFF0,
      lightEnd: 0xFFFFFFF,
      darkStart: 0xFF101820,
      darkEnd: 0xFF101820);

  static Color get dialogClose =>
      getColor(darkMode, light: 0xFF788489, dark: 0xFFC1C5C8);

  static Color get inactvePrayerMenu =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF005780);

  static Color get tabBackground =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF005780);

  static Color get inactveTabMenu =>
      getColor(darkMode, light: 0xFF718B92, dark: 0xB3FFFFFF);

  static Color get actveTabMenu =>
      getColor(darkMode, light: 0xFF009FD0, dark: 0xFF009FD0);

  static Color get textFieldBackgroundColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF022F52);
  static Color get appBarColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF002D4B);

  static Color get prayerPrimaryColor =>
      getColor(darkMode, light: 0xFF5EC2E1, dark: 0xFF014E75);
  static Color get prayerMenuColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF005780);
  static Color get prayerCardBgColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF012B4D);
  static Color get dropShadow =>
      getColor(darkMode, light: 0xFFBBBDBF, dark: 0xFF011D3D);
  static Color get activeButton =>
      getColor(darkMode, light: 0xFF9BD4E5, dark: 0xFF025584);
  static Color get cardBorder =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF004E75);
  static Color get slideBorder =>
      getColor(darkMode, light: 0xFFEDEFF0, dark: 0xFF004E75);
  static Color get divider =>
      getColor(darkMode, light: 0xFF0D1319, dark: 0xFF005780);
  static Color get textFieldText =>
      getColor(darkMode, light: 0xFF002D4B, dark: 0xFFC1C5C8);
  static Color get textFieldBorder =>
      getColor(darkMode, light: 0xFFB4E3F1, dark: 0xFF014C73);
  static Color get prayeModeBg =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF0D1319);
  static Color get prayerModeBorder =>
      getColor(darkMode, light: 0xFF009FD0, dark: 0xFF005882);
  static Color get splashTextColor =>
      getColor(darkMode, light: 0xFF005780, dark: 0xFF00ACD8);
  static Color get bottomNavIconColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF009FD0);
  static Color get topNavTextColor =>
      getColor(darkMode, light: 0xFF003B87, dark: 0xFF009FD0);
  static Color get drawerTopColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0XFF0D1319);
  static Color get prayerTextColor =>
      getColor(darkMode, light: 0xFF002D4B, dark: 0XFFC1C5C8);
  static Color get addPrayerTextColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0XFF009FD0);
  static Color get addPrayerBgColor =>
      getColor(darkMode, light: 0xFF009FD0, dark: 0XFF021D3C);
  static Color get prayerDetailsBgColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0XFF03274F);
  static Color get groupCardBgColor =>
      getColor(darkMode, light: 0xFFFFFFFF, dark: 0xFF021D3C);
  static Color get groupActionBgColor =>
      getColor(darkMode, light: 0xFF009FD0, dark: 0xFF012B4D);
  static Color get drawerMenuColor =>
      getColor(darkMode, light: 0xFF009FD0, dark: 0xFF718B92);
  static Color get addPrayerBg =>
      getColor(darkMode, light: 0xFF0D1319, dark: 0xFF0D1319);
  static Color get saveBtnBorder =>
      getColor(darkMode, light: 0xFF004E75, dark: 0xFF004E75);
  static Color get blueTitle =>
      getColor(darkMode, light: 0xFF003B87, dark: 0xFF00ACD8);

  static const List<Color> customLogoShaperadient = [
    const Color(0xFF005177),
    const Color(0xFF001B42)
  ];
  static const Color shadowColor = const Color(0xFF001439);

  static const Color white = const Color(0xFFFFFFFF);
  static const Color offWhite1 = const Color(0xFF005780);
  static const Color offWhite2 = const Color(0xFFAFBAC4);
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
  static const Color grey4 = const Color(0xFF788489);

  static const Color red = const Color(0xFFF93549);

  static const Color darkBlue = const Color(0xFF1B3A5E);
  static const Color darkBlue2 = const Color(0xFF015380);
  static const Color darkBlue3 = const Color(0xFF31373D);

  static const Color yaleBlue = const Color(0xFF004A98);
  static const Color prussianBlue = const Color(0xFF002D4B);

  static const Color drawerGrey = const Color(0xFF718B92);
  static const Color splashLogo = const Color(0xFF005780);
}

class AppTextStyles {
  static TextStyle get medium10 => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  static const TextStyle regularText11 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText12 = const TextStyle(
    color: AppColors.lightBlue5,
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
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
  static const TextStyle regularText15 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText15b = const TextStyle(
    color: AppColors.offWhite4,
    fontSize: 15,
    fontWeight: FontWeight.w300,
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
  static const TextStyle regularText20 = const TextStyle(
    height: 1.44,
    color: AppColors.lightBlue4,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  static const TextStyle regularText22 = const TextStyle(
    height: 1.44,
    color: AppColors.offWhite4,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText14 = const TextStyle(
    color: AppColors.lightBlue1,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText16 = const TextStyle(
    color: AppColors.lightBlue1,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText18 = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 18,
    fontWeight: FontWeight.w700,
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
  static const TextStyle boldText16b = const TextStyle(
    color: AppColors.lightBlue4,
    fontSize: 16.8,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText28 = const TextStyle(
    color: AppColors.grey3,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle boldText30 = const TextStyle(
    color: AppColors.grey3,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle demiboldText34 = const TextStyle(
    color: AppColors.offWhite2,
    fontSize: 34,
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
  static const TextStyle prayerText = const TextStyle(
    color: AppColors.offWhite2,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.1,
  );

  static const TextStyle normalDarkBlue = const TextStyle(
    color: AppColors.darkBlue,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 1,
  );
  static const TextStyle drawerMenu = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}
