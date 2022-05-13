import 'dart:async';
import 'package:flutter/material.dart';

import 'flavor_config.dart';
import 'main.dart' as common;

Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.STORE,
    color: Colors.green,
    values: FlavorValues(
        country: 'US',
        packageName: 'org.second.bestill.v2',
        dynamicLink: 'bestillapp.page.link',
        appUrl: 'https://be-still-v2.firebaseapp.com'),
  );
  common.main();
}
