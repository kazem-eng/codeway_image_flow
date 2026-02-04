import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class CaptureModel {
  const CaptureModel({
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

  CaptureModel copyWith({
    ImageSource? selectedSource,
    Uint8List? capturedImage,
    bool? isProcessing,
    bool? hasPermission,
    bool? showSourceDialog,

  }) {
    return CaptureModel(
      selectedSource: selectedSource ?? this.selectedSource,
      capturedImage: capturedImage ?? this.capturedImage,
      isProcessing: isProcessing ?? this.isProcessing,
      hasPermission: hasPermission ?? this.hasPermission,
      showSourceDialog: showSourceDialog ?? this.showSourceDialog,
    );
  }
}
