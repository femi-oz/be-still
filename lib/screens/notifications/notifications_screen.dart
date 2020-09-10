import 'package:be_still/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Text('test'),
      ),
    );
  }
}
