import 'dart:typed_data';

import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

/// Swipeable image with label (original / filtered).
class SwipeImage extends StatelessWidget {
  const SwipeImage({super.key, required this.bytes, required this.label});

  final Uint8List bytes;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: ImageFlowSpacing.sm),
          child: Text(label, style: ImageFlowTextStyles.bodySmall),
        ),
        Expanded(
          child: InteractiveViewer(
            child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
          ),
        ),
      ],
    );
  }
}
