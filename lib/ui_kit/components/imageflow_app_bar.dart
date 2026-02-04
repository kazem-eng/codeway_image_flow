import 'package:flutter/material.dart';

import '../styles/decorations.dart';
import '../styles/theme_data.dart';

/// Reusable AppBar component for ImageFlow screens.
class ImageFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImageFlowAppBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.titleSpacing,
    this.actions,
  });

  /// The title text to display.
  final String title;

  /// Optional title text style. Defaults to [ImageFlowTextStyles.screenTitle].
  /// Use [ImageFlowTextStyles.appTitle] for the home screen.
  final TextStyle? titleStyle;

  /// Optional title spacing. Defaults to theme default.
  /// Use 56 for the home screen.
  final double? titleSpacing;

  /// Optional action buttons (e.g. delete button).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: titleStyle ?? ImageFlowTextStyles.screenTitle),
      titleSpacing: titleSpacing,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(ImageFlowSizes.appBarHeight);
}
