import 'package:flutter/material.dart';

import '../styles/styles_export.dart';

/// ImageFlow dark theme.
class ImageFlowTheme {
  ImageFlowTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ImageFlowColors.background,

      colorScheme: const ColorScheme.dark(
        primary: ImageFlowColors.primaryStart,
        secondary: ImageFlowColors.secondary,
        surface: ImageFlowColors.surface,
        error: ImageFlowColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ImageFlowColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ImageFlowTextStyles.screenTitle,
        toolbarHeight: ImageFlowSizes.appBarHeight,
        titleSpacing: ImageFlowSizes.appBarLeftPadding,
        leadingWidth: ImageFlowSizes.appBarHeight,
        iconTheme: const IconThemeData(
          color: ImageFlowColors.textPrimary,
          size: ImageFlowSizes.iconMedium,
        ),
        actionsIconTheme: const IconThemeData(
          color: ImageFlowColors.textPrimary,
          size: ImageFlowSizes.iconMedium,
        ),
      ),
      cardTheme: CardThemeData(
        color: ImageFlowColors.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ImageFlowShapes.roundedMedium(),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ImageFlowColors.primaryStart,
        foregroundColor: ImageFlowColors.textPrimary,
        elevation: 8,
      ),
    );
  }
}
