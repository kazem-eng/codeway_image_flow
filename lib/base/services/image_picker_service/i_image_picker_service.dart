import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Image picker service interface.
abstract class IImagePickerService {
  /// Picks an image from the specified source.
  /// Returns the image bytes if successful, null if cancelled.
  /// Throws exceptions for permission or I/O errors.
  Future<Uint8List?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
  });
}
