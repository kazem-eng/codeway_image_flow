import 'package:flutter/material.dart';

import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes_handler.dart';
import 'package:codeway_image_processing/base/services/navigation_service/route_observer.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/theme/theme_export.dart';

/// Root app widget.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    setupLocator(navigatorKey: _navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeProvider.theme,
      navigatorKey: _navigatorKey,
      navigatorObservers: [routeObserver],
      initialRoute: Routes.home,
      onGenerateRoute: RoutesHandler.onGenerateRoute,
    );
  }
}
