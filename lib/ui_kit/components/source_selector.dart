import 'package:flutter/material.dart';

import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/colors_model.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';

/// Source selection (camera / gallery). Reused in Home and Capture.
class SourceSelector extends StatelessWidget {
  const SourceSelector({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.chooseSource, style: ImageFlowTextStyles.screenTitle),
        SizedBox(height: ImageFlowSpacing.lg),
        _SourceTile(
          icon: Icons.camera_alt,
          label: AppStrings.camera,
          onTap: onCamera,
        ),
        SizedBox(height: ImageFlowSpacing.md),
        _SourceTile(
          icon: Icons.photo_library,
          label: AppStrings.gallery,
          onTap: onGallery,
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ImageFlowColors.surfaceVariant,
      borderRadius: ImageFlowShapes.roundedMedium(),
      child: InkWell(
        onTap: onTap,
        borderRadius: ImageFlowShapes.roundedMedium(),
        child: Padding(
          padding: ImageFlowSpacing.sourceTilePadding,
          child: Row(
            children: [
              Container(
                width: ImageFlowSizes.sourceTileIconSize,
                height: ImageFlowSizes.sourceTileIconSize,
                decoration: ImageFlowDecorations.sourceTileIcon(),
                child: Icon(
                  icon,
                  size: ImageFlowSizes.iconSmall,
                  color: ImageFlowColors.primaryStart,
                ),
              ),
              SizedBox(width: ImageFlowSpacing.md),
              Text(label, style: ImageFlowTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
