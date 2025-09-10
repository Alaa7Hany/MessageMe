import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? pushNamed(String routeName, {Object? arguments}) {
    // Ensure the navigatorKey has a current state before attempting to navigate
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }
}
