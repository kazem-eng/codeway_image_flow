import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/decorations.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:codeway_image_processing/ui_kit/utils/date_formats.dart';
import 'package:codeway_image_processing/ui_kit/utils/file_size_formats.dart';

class MetadataDisplay extends StatelessWidget {
  const MetadataDisplay({
    super.key,
    required this.dateMillis,
    required this.processingType,
    this.fileSize,
  });

  final int dateMillis;
  final ProcessingType processingType;
  final int? fileSize;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormats.formatDateOnly(dateMillis);
    final typeStr = processingType.isFace
        ? AppStrings.face
        : AppStrings.documentType;
    final sizeStr = FileSizeFormats.formatFileSize(fileSize);

    return Container(
      padding: ImageFlowSpacing.cardPadding,
      decoration: ImageFlowDecorations.metadataTop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ImageFlowSpacing.rowGap,
        children: [
          _row(AppStrings.date, dateStr),
          _row(AppStrings.type, typeStr),
          _row(AppStrings.size, sizeStr),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: ImageFlowTextStyles.bodySmall),
        Text(value, style: ImageFlowTextStyles.bodyMedium),
      ],
    );
  }
}
