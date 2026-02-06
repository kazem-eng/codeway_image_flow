import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// State model for the source selector dialog.
class SourceSelectorDialogModel {
  const SourceSelectorDialogModel({
    this.selectedSource,
    this.capturedImage,
    this.isProcessing = false,
    this.hasPermission = false,
    this.showSourceDialog = true,
  });

  final ImageSource? selectedSource;
  final Uint8List? capturedImage;
  final bool isProcessing;
  final bool hasPermission;
  final bool showSourceDialog;

  SourceSelectorDialogModel copyWith({
    ImageSource? selectedSource,
    Uint8List? capturedImage,
    bool? isProcessing,
    bool? hasPermission,
    bool? showSourceDialog,
  }) {
    return SourceSelectorDialogModel(
      selectedSource: selectedSource ?? this.selectedSource,
      capturedImage: capturedImage ?? this.capturedImage,
      isProcessing: isProcessing ?? this.isProcessing,
      hasPermission: hasPermission ?? this.hasPermission,
      showSourceDialog: showSourceDialog ?? this.showSourceDialog,
    );
  }
}
