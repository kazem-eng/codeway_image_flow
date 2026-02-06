import 'package:flutter/material.dart';

import '../styles/colors_model.dart';

/// Visual styles for ImageFlow toast.
enum ImageFlowToastStyle { info, success, warning, error }

/// Resolved style values for an ImageFlow toast.
class ImageFlowToastStyleConfig {
  const ImageFlowToastStyleConfig({
    required this.accent,
    required this.icon,
    required this.duration,
  });

  final Color accent;
  final IconData icon;
  final Duration duration;

  static ImageFlowToastStyleConfig fromStyle(ImageFlowToastStyle style) {
    switch (style) {
      case ImageFlowToastStyle.error:
        return const ImageFlowToastStyleConfig(
          accent: ImageFlowColors.error,
          icon: Icons.error_outline,
          duration: Duration(milliseconds: 2600),
        );
      case ImageFlowToastStyle.warning:
        return const ImageFlowToastStyleConfig(
          accent: ImageFlowColors.warning,
          icon: Icons.info_outline,
          duration: Duration(milliseconds: 2200),
        );
      case ImageFlowToastStyle.success:
        return const ImageFlowToastStyleConfig(
          accent: ImageFlowColors.success,
          icon: Icons.check,
          duration: Duration(milliseconds: 1800),
        );
      case ImageFlowToastStyle.info:
        return const ImageFlowToastStyleConfig(
          accent: ImageFlowColors.accentPurple,
          icon: Icons.notifications_none,
          duration: Duration(milliseconds: 2000),
        );
    }
  }
}
