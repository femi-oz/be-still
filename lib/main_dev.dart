import 'dart:async';
import 'package:flutter/material.dart';

import './flavor_config.dart';
import './main.dart' as common;

Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.DEV,
    color: Colors.green,
    values: FlavorValues(
        country: 'NG',
        packageName: 'org.second.bestill.dev',
        dynamicLink: 'bestill.page.link',
        appUrl: 'https://bestill-app.firebaseapp.com'),
  );
  common.main();
}
