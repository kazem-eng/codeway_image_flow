import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'i_image_picker_service.dart';

/// Image picker service implementation using image_picker package.
class ImagePickerService implements IImagePickerService {
  ImagePickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
  }) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    if (xFile == null) return null;
    return await xFile.readAsBytes();
  }
}
