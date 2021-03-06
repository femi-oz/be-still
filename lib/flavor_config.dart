import 'package:flutter/material.dart';

import 'utils/string_utils.dart';

enum Flavor {
  DEV,
  PROD,
  STAGING,
  STORE,
}

class FlavorValues {
  final String country;
  final String packageName;
  final String dynamicLink;
  final String appUrl;
  //Add other flavor specific values, e.g database name

  FlavorValues({
    required this.country,
    required this.packageName,
    required this.dynamicLink,
    required this.appUrl,
  });
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color color;
  final FlavorValues values;

  static FlavorConfig _instance = FlavorConfig(
      flavor: Flavor.PROD,
      values: FlavorValues(
          appUrl: '', country: '', dynamicLink: '', packageName: ''));

  factory FlavorConfig({
    required Flavor flavor,
    Color color: Colors.blue,
    required FlavorValues values,
  }) {
    _instance = FlavorConfig._internal(
        flavor, StringUtils.enumName(flavor.toString()), color, values);
    return _instance;
  }

  FlavorConfig._internal(this.flavor, this.name, this.color, this.values);

  static FlavorConfig get instance {
    return _instance;
  }

  static bool isProduction() => _instance.flavor == Flavor.PROD;
  static bool isDev() => _instance.flavor == Flavor.DEV;
  static bool isStaging() => _instance.flavor == Flavor.STAGING;
  static bool isStore() => _instance.flavor == Flavor.STORE;
}
