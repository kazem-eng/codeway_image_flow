import 'package:flutter/material.dart';

import 'i_navigation_service.dart';

/// Navigation service using NavigatorKey (no GetX navigation).
class NavigationService implements INavigationService {
  NavigationService({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  BuildContext? get _context => _navigatorKey.currentContext;

  @override
  Future<void> goTo(String route, {Object? arguments}) async {
    if (_context == null) return;
    await Navigator.of(_context!).pushNamed(route, arguments: arguments);
  }

  @override
  Future<void> replaceWith(String route, {Object? arguments}) async {
    if (_context == null) return;
    await Navigator.of(_context!).pushReplacementNamed(
      route,
      arguments: arguments,
    );
  }

  @override
  void goBack() {
    if (_context == null) return;
    Navigator.of(_context!).pop();
  }

  @override
  Future<void> goBackUntil(String route) async {
    if (_context == null) return;
    Navigator.of(_context!).popUntil((r) => r.settings.name == route);
  }
}
