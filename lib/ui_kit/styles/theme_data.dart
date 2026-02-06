import 'package:flutter/material.dart';

import 'colors_model.dart';

/// ImageFlow text styles and spacing.
class ImageFlowTextStyles {
  ImageFlowTextStyles._();

  static const TextStyle appTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ImageFlowColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ImageFlowColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ImageFlowColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ImageFlowColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ImageFlowColors.textTertiary,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ImageFlowColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle statusText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ImageFlowColors.textSecondary,
  );

  static const TextStyle pdfCardTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: ImageFlowColors.primaryStart,
  );

  /// Dialog title (e.g. AlertDialog).
  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ImageFlowColors.textPrimary,
  );

  /// Dialog body text.
  static const TextStyle dialogContent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ImageFlowColors.textSecondary,
  );

  /// Destructive action (e.g. Delete button).
  static const TextStyle destructiveAction = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ImageFlowColors.error,
  );

  /// Progress label (e.g. "Processing...").
  static const TextStyle progressLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: ImageFlowColors.textPrimary,
  );

  /// Full-screen viewer app bar title.
  static const TextStyle fullScreenAppBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ImageFlowColors.textPrimary,
  );

  /// Primary dialog action (e.g. Open Settings).
  static const TextStyle dialogAction = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ImageFlowColors.primaryStart,
  );

  /// Neutral dialog action (e.g. Cancel).
  static const TextStyle dialogActionNeutral = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ImageFlowColors.textSecondary,
  );
}

class ImageFlowSpacing {
  ImageFlowSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(32.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    md,
    md,
    md,
    lg,
  );

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  /// Dialog content padding.
  static const EdgeInsets dialogContentPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 20,
  );

  /// Source tile padding (camera/gallery choice).
  static const EdgeInsets sourceTilePadding = EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 16,
  );

  /// Row gap in metadata / lists.
  static const double rowGap = 12.0;
}
