import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/devotional_service.dart';
import 'package:be_still/services/group_prayer_service.dart';
import 'package:be_still/services/group_service.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:be_still/services/v2/auth_service.dart';
import 'package:be_still/services/v2/devotional_service.dart';
import 'package:be_still/services/v2/group_service.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => PrayerService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => GroupService());
  locator.registerLazySingleton(() => GroupPrayerService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => DevotionalService());
  locator.registerLazySingleton(() => LogService());
// ------------------------------------------------------------------
  locator.registerLazySingleton(() => NotificationServiceV2());
  locator.registerLazySingleton(() => AuthenticationServiceV2());
  locator.registerLazySingleton(() => PrayerServiceV2());
  locator.registerLazySingleton(() => UserServiceV2());
  locator.registerLazySingleton(() => GroupServiceV2());
  locator.registerLazySingleton(() => DevotionalServiceV2());
}
