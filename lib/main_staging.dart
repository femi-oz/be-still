import 'dart:async';
import 'package:flutter/material.dart';

import 'flavor_config.dart';
import 'main.dart' as common;

Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.STAGING,
    color: Colors.green,
    values: FlavorValues(country: 'US', packageName: 'org.second.bestill.test'),
  );
  common.main();
}
