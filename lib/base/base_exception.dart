/// Base exception for the application.
abstract class BaseException implements Exception {
  BaseException({required this.message, this.prefix = ''});

  final String message;
  final String prefix;

  @override
  String toString() => '$prefix$message';
}

class StorageException extends BaseException {
  StorageException({required super.message}) : super(prefix: 'Storage Error: ');
}

class FaceDetectionException extends BaseException {
  FaceDetectionException({required super.message})
    : super(prefix: 'Face Detection Error: ');
}

class ImageProcessingException extends BaseException {
  ImageProcessingException({required super.message})
    : super(prefix: 'Image Processing Error: ');
}

class FileStorageException extends BaseException {
  FileStorageException({required super.message})
    : super(prefix: 'File Storage Error: ');
}
