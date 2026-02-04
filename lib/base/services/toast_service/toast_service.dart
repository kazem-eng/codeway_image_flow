import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

import 'i_toast_service.dart';

/// Shows toasts as SnackBars using the app navigator context.
class ToastService implements IToastService {
  ToastService({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  @override
  void show(String message) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: ImageFlowTextStyles.bodyLarge),
        backgroundColor: ImageFlowColors.secondary,
        behavior: SnackBarBehavior.floating,
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation<double>(1.0),
          curve: Curves.bounceIn,
          reverseCurve: Curves.bounceOut,
        ),
        margin: const EdgeInsets.fromLTRB(
          ImageFlowSpacing.md,
          0,
          ImageFlowSpacing.md,
          ImageFlowSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ImageFlowSpacing.borderRadiusMedium,
          ),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
