import 'package:codeway_image_processing/base/services/navigation_service/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationService', () {
    late GlobalKey<NavigatorState> navigatorKey;
    late NavigationService navigationService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      navigatorKey = GlobalKey<NavigatorState>();
      navigationService = NavigationService(navigatorKey: navigatorKey);
    });

    test('should return early when context is null for goTo', () async {
      // Act
      await navigationService.goTo('/test');

      // Assert - should not throw, just return early
      expect(navigatorKey.currentContext, isNull);
    });


    test('should return early when context is null for goBack', () {
      // Act
      navigationService.goBack();

      // Assert - should not throw, just return early
      expect(navigatorKey.currentContext, isNull);
    });

    test('should return early when context is null for goBackUntil', () async {
      // Act
      await navigationService.goBackUntil('/test');

      // Assert - should not throw, just return early
      expect(navigatorKey.currentContext, isNull);
    });


    // Note: Full integration tests would require a MaterialApp context
    // These tests verify the null-safety behavior which is important
  });
}
