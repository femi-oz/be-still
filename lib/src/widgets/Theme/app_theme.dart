import 'package:flutter/material.dart';

enum AppTheme { DarkTheme, LightTheme }
final appThemeData = {
  AppTheme.DarkTheme: ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: Color(0xFF0D1319),
    ),
  ),
  AppTheme.LightTheme: ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Color(0xFFFFFFFF),
    ),
  ),
};

extension ThemeContext on BuildContext {
  Color dynamicColor({int light, int dark}) {
    return (Theme.of(this).brightness == Brightness.light)
        ? Color(light)
        : Color(dark);
  }

  Color dynamicColour({Color light, Color dark}) {
    return (Theme.of(this).brightness == Brightness.light) ? light : dark;
  }

  Color get brightBlue => dynamicColor(light: 0xFF00ACD8, dark: 0xFF00ACD8);
  Color get brightBlue2 => dynamicColor(light: 0xFF009FD0, dark: 0xFF009FD0);
  Color get dimBlue => dynamicColor(light: 0xFF01537B, dark: 0xFF01537B);
  Color get offWhite => dynamicColor(light: 0xFFC1C5C8, dark: 0xFFC1C5C8);

  Color get mainBgStart => dynamicColor(light: 0xFFEDEFF0, dark: 0xFF021D3C);
  Color get mainBgEnd => dynamicColor(light: 0xFFEDEFF0, dark: 0xFF073668);

  Color get prayerMenuStart =>
      dynamicColor(light: 0xFF00438D, dark: 0xFF014A70);
  Color get prayerMenuEnd => dynamicColor(light: 0xFF009CCE, dark: 0xFF013053);
  Color get prayerMenuInactive =>
      dynamicColor(light: 0xFFFFFFFF, dark: 0xFF005780);

  Color get prayerNotAvailable =>
      dynamicColor(light: 0xFF193452, dark: 0xFF193452);

  Color get prayerCardBorder =>
      dynamicColor(light: 0xFFEDEFF0, dark: 0xFF00547D);
  Color get prayerDivider => dynamicColor(light: 0xFF0D1319, dark: 0xFF00547D);
  Color get prayerCardBg => dynamicColor(light: 0xFFFFFFFF, dark: 0xFF012B4D);
  Color get prayerReminderIcon =>
      dynamicColor(light: 0xFF0091C0, dark: 0xFF0091C0);
  Color get prayerCardPrayer =>
      dynamicColor(light: 0xFF00537b, dark: 0xFFC1C5C8);
  Color get prayerCardTags => dynamicColor(light: 0xFFbf0606, dark: 0xFFbf0606);

  Color get toolsActiveBtn => dynamicColor(light: 0xFF9BD4E5, dark: 0xFF025584);
  Color get toolsBtnBorder => dynamicColor(light: 0xFF027BA6, dark: 0xFF027BA6);
  Color get toolsBackBtn => dynamicColor(light: 0xFF01486C, dark: 0xFF01486C);
  Color get toolsBg => dynamicColor(light: 0xFFE6E9ED, dark: 0xFF06213B);

  Color get inputFieldBg => dynamicColor(light: 0xFFFFFFFF, dark: 0xFF022F52);
  Color get inputFieldText => dynamicColor(light: 0xFF79858A, dark: 0xFFC1C5C8);
  Color get inputFieldBorder =>
      dynamicColor(light: 0xFFA1DBED, dark: 0xFF004D74);

  Color get addNewPrayerBtnBorder =>
      dynamicColor(light: 0xFF0090C0, dark: 0xFF0090C0);

  Color get appBarActive => dynamicColor(light: 0xFF005780, dark: 0xFF002D4B);
  Color get appBarInactive => dynamicColor(light: 0xFF51575C, dark: 0xFF51575C);
  Color get prayerDetailsCardStart =>
      dynamicColor(light: 0xFFf0f4fa, dark: 0xFF012B4C);
  Color get prayerDetailsCardEnd =>
      dynamicColor(light: 0xFFE6E9ED, dark: 0xFF033565);
  Color get prayerDetailsCardBorder =>
      dynamicColor(light: 0xFF015380, dark: 0xFF015380);

  Color get prayModeBg => dynamicColor(light: 0xFFE6E9ED, dark: 0xFF101820);
  Color get prayModeCardBorder =>
      dynamicColor(light: 0xFF0C3A4C, dark: 0xFF0C3A4C);

  Color get authPainterStart =>
      dynamicColor(light: 0xFF005177, dark: 0xFF005177);
  Color get authPainterEnd => dynamicColor(light: 0xFF001B42, dark: 0xFF001B42);
  Color get authPainterShadow =>
      dynamicColor(light: 0xFF001439, dark: 0xFF001439);
  Color get authBtnStart => dynamicColor(light: 0xFF005882, dark: 0xFF005882);
  Color get authBtnEnd => dynamicColor(light: 0xFF009DCE, dark: 0xFF009DCE);
  Color get switchThumbActive =>
      dynamicColor(light: 0xFF009FD0, dark: 0xFF009FD0);

  Color get bibleExpandeablePanelHeader =>
      dynamicColor(light: 0xFFCBDCF7, dark: 0xFF023C63);
  Color get bibleExpandeablePanelBody =>
      dynamicColor(light: 0xFFE6E9ED, dark: 0xFF022144);

  Color get devotionalGrey => dynamicColor(light: 0xFF00537b, dark: 0xFF788489);

  Color get settingsTitle => dynamicColor(light: 0xFF003B87, dark: 0xFF31373D);
  Color get settingsHeader => dynamicColor(light: 0xFFFFFFFF, dark: 0xFFC1C5C8);
  Color get settingsUsername =>
      dynamicColor(light: 0xFF004166, dark: 0xFF004166);

  Color get dropShadow => dynamicColor(light: 0xFFbbbdbf, dark: 0xFF011D3D);
}