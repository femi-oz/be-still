import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

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
