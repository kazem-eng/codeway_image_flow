import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';

/// Processing step enum for the processing screen.
enum ProcessingStep {
  initializing,
  detectingContent,
  detectingFaces,
  detectingDocument,
  processingDocument,
  creatingPdf,
  saving,
  done;

  /// Display text for the processing step.
  String get displayText {
    switch (this) {
      case ProcessingStep.initializing:
        return AppStrings.initializing;
      case ProcessingStep.detectingContent:
        return AppStrings.detectingContent;
      case ProcessingStep.detectingFaces:
        return AppStrings.detectingFaces;
      case ProcessingStep.detectingDocument:
        return AppStrings.detectingDocument;
      case ProcessingStep.processingDocument:
        return AppStrings.processingDocument;
      case ProcessingStep.creatingPdf:
        return AppStrings.creatingPdf;
      case ProcessingStep.saving:
        return AppStrings.saving;
      case ProcessingStep.done:
        return AppStrings.done;
    }
  }
}
