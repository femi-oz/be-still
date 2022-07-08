import 'dart:async';
import 'package:flutter/material.dart';

import 'flavor_config.dart';
import 'main.dart' as common;

Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.STAGING,
    color: Colors.green,
    values: FlavorValues(
        country: 'US',
        packageName: 'org.second.bestill.test',
        dynamicLink: 'bestilltest.page.link',
        appUrl: 'https://bestill-app.firebaseapp.com'),
  );
  common.main();
}
