import 'package:flutter/material.dart';

import '../styles/styles_export.dart';

/// Primary gradient button.
class ImageFlowButton extends StatelessWidget {
  const ImageFlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ImageFlowSizes.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ImageFlowColors.primaryStart, ImageFlowColors.primaryEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: ImageFlowShapes.roundedMedium(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: ImageFlowShapes.roundedMedium(),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ImageFlowColors.textPrimary,
                    ),
                  )
                : Text(label, style: ImageFlowTextStyles.buttonLarge),
          ),
        ),
      ),
    );
  }
}
