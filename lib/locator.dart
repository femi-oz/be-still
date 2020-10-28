import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/group_service.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/prayer_settings_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/sharing_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:get_it/get_it.dart';
// import 'package:stacked_services/stacked_services.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => PrayerService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => SharingSettingsService());
  locator.registerLazySingleton(() => PrayerSettingsService());
  locator.registerLazySingleton(() => GroupService());
  // locator.registerLazySingleton(() => DialogService());
}
