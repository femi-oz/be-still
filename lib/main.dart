import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'Providers/app_provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => AppProvider()),
        ],
        child: MyApp(),
      ),
    );
