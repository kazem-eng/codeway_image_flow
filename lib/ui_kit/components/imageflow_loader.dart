import 'package:flutter/material.dart';

import '../styles/colors_model.dart';
import '../styles/theme_data.dart';

/// Centered loading indicator.
class ImageFlowLoader extends StatelessWidget {
  const ImageFlowLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: ImageFlowSpacing.md,
        children: [
          const CircularProgressIndicator(color: ImageFlowColors.primaryStart),
          if (message != null)
            Text(message!, style: ImageFlowTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
