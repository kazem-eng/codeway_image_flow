import 'package:flutter/material.dart';

import 'colors_model.dart';
import 'theme_data.dart';

/// ImageFlow shadow definitions.
class ImageFlowShadows {
  ImageFlowShadows._();

  static List<BoxShadow> get fabShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

/// ImageFlow decoration utilities.
class ImageFlowDecorations {
  ImageFlowDecorations._();

  /// Card decoration with surface variant background
  static BoxDecoration card({
    Color? color,
    double? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? ImageFlowColors.surfaceVariant,
      borderRadius: BorderRadius.circular(
        borderRadius ?? ImageFlowSpacing.borderRadiusMedium,
      ),
      border: border,
    );
  }

  /// Inner card decoration (darker background)
  static BoxDecoration innerCard({double? borderRadius}) {
    return BoxDecoration(
      color: const Color(0xFF2C2D35), // Inner card color
      borderRadius: BorderRadius.circular(
        borderRadius ?? ImageFlowSpacing.borderRadiusSmall,
      ),
    );
  }

  /// PDF card decoration with border
  static BoxDecoration pdfCard({Color? borderColor, double? borderWidth}) {
    return BoxDecoration(
      color: const Color(0xFF2C2D35),
      border: Border.all(
        color: borderColor ?? ImageFlowColors.primaryStart,
        width: borderWidth ?? 3,
      ),
      borderRadius: BorderRadius.circular(ImageFlowSpacing.borderRadiusLarge),
    );
  }

  /// Gradient icon container decoration
  static BoxDecoration gradientIcon({
    required Color color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(
        borderRadius ?? ImageFlowSizes.sourceTileIconRadius,
      ),
    );
  }

  /// FAB decoration (gradient + shadow).
  static BoxDecoration fab() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [ImageFlowColors.primaryStart, ImageFlowColors.primaryEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(ImageFlowSizes.fabBorderRadius),
      boxShadow: ImageFlowShadows.fabShadow,
    );
  }

  /// Dialog shape (RoundedRectangleBorder).
  static ShapeBorder dialogShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ImageFlowSpacing.borderRadiusLarge),
    );
  }

  /// Source tile (camera/gallery option) container.
  static BoxDecoration sourceTile() {
    return BoxDecoration(
      color: ImageFlowColors.surfaceVariant,
      borderRadius: BorderRadius.circular(ImageFlowSpacing.borderRadiusMedium),
    );
  }

  /// Source tile icon container.
  static BoxDecoration sourceTileIcon() {
    return BoxDecoration(
      color: ImageFlowColors.surface,
      borderRadius: BorderRadius.circular(ImageFlowSizes.sourceTileIconRadius),
    );
  }

  /// Metadata strip (top rounded only).
  static BoxDecoration metadataTop() {
    return BoxDecoration(
      color: ImageFlowColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(ImageFlowSpacing.borderRadiusLarge),
      ),
    );
  }

  /// Progress bar track (clip).
  static BorderRadius progressBarClip() {
    return BorderRadius.circular(ImageFlowSizes.progressBarRadius);
  }
}

/// ImageFlow shape utilities.
class ImageFlowShapes {
  ImageFlowShapes._();

  /// Rounded rectangle border radius
  static BorderRadius rounded({double? radius}) {
    return BorderRadius.circular(radius ?? ImageFlowSpacing.borderRadiusMedium);
  }

  /// Small rounded rectangle
  static BorderRadius roundedSmall() {
    return BorderRadius.circular(ImageFlowSpacing.borderRadiusSmall);
  }

  /// Medium rounded rectangle
  static BorderRadius roundedMedium() {
    return BorderRadius.circular(ImageFlowSpacing.borderRadiusMedium);
  }

  /// Large rounded rectangle
  static BorderRadius roundedLarge() {
    return BorderRadius.circular(ImageFlowSpacing.borderRadiusLarge);
  }
}

/// ImageFlow size constants.
class ImageFlowSizes {
  ImageFlowSizes._();

  // Icon sizes
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;

  // Container sizes
  static const double iconContainer = 44;
  static const double buttonHeight = 56;
  static const double appBarHeight = 56;
  static const double appBarLeftPadding = 0;

  // Image sizes
  static const double thumbnailSize = 44;
  static const double batchItemThumbnailSize = 56;
  static const double faceThumbnailSize = 72;
  static const double thumbnailDeleteSize = 18;
  static const double thumbnailDeleteIconSize = 12;
  static const double thumbnailDeleteOffset = 4;
  static const double previewImageHeight = 140;
  static const double previewCardMinHeight = 160;
  static const double previewCardOuterMinHeight = 200;
  static const double documentPreviewHeight = 220;

  // Face preview
  static const double facePreviewHeightFactor = 0.52;

  // Padding values
  static const double cardInnerPadding = 16;
  static const double cardOuterPadding = 24;
  static const double itemBottomMargin = 12;

  // FAB
  static const double fabSize = 56;
  static const double fabBorderRadius = 28;

  // Progress bar
  static const double progressBarHeight = 4;
  static const double progressBarHeightLarge = 8;
  static const double progressBarRadius = 2;

  // Source tile (camera/gallery)
  static const double sourceTileIconSize = 36;
  static const double sourceTileIconRadius = 10;
}
