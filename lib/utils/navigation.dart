import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(Widget _rn) {
    return navigationKey.currentState.pushReplacement(PageTransition(
        type: PageTransitionType.rightToLeftWithFade, child: _rn));
  }

  Future<dynamic> goHome(int index) async {
    await Provider.of<MiscProvider>(navigationKey.currentContext, listen: false)
        .setCurrentPage(index);
    return navigationKey.currentState.pushReplacement(PageTransition(
        type: PageTransitionType.leftToRightWithFade, child: EntryScreen()));
  }

  Future<dynamic> navigateTo(String _rn) {
    return navigationKey.currentState.pushNamed(_rn);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _rn) {
    return navigationKey.currentState.push(_rn);
  }

  goback() {
    return navigationKey.currentState.pop();
  }
}
