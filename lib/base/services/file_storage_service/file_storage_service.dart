import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../base_exception.dart';
import '../../../features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'i_file_storage_service.dart';

/// Saves/loads images and PDFs under app documents directory.
/// Throws [FileStorageException] on I/O or path errors.
class FileStorageService implements IFileStorageService {
  static const String processedImagesDir = 'processed_images';
  static const String facesDir = 'faces';
  static const String documentsDir = 'documents';
  static const String thumbnailsDir = 'thumbnails';

  FileStorageException _wrap(Object e, [String? context]) {
    final msg = context != null ? '$context: ${e.toString()}' : e.toString();
    return FileStorageException(message: msg);
  }

  @override
  Future<String> getStorageDirectory(String subdirectory) async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, subdirectory));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    } on IOException catch (e) {
      throw _wrap(e, 'Failed to get or create directory $subdirectory');
    } catch (e) {
      throw _wrap(e, 'getStorageDirectory');
    }
  }

  @override
  Future<String> saveProcessedImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final base = await getStorageDirectory(processedImagesDir);
      final path = p.join(base, fileName);
      await File(path).parent.create(recursive: true);
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      return path;
    } on FileStorageException {
      rethrow;
    } on IOException catch (e) {
      throw _wrap(e, 'saveProcessedImage($fileName)');
    } catch (e) {
      throw _wrap(e, 'saveProcessedImage');
    }
  }

  @override
  Future<String> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      final base = await getStorageDirectory(processedImagesDir);
      final path = p.join(base, fileName);
      await File(path).parent.create(recursive: true);
      final file = File(path);
      await file.writeAsBytes(pdfBytes);
      return path;
    } on FileStorageException {
      rethrow;
    } on IOException catch (e) {
      throw _wrap(e, 'savePdf($fileName)');
    } catch (e) {
      throw _wrap(e, 'savePdf');
    }
  }

  @override
  Future<String> saveThumbnail(Uint8List imageBytes, String fileName) async {
    try {
      final base = await getStorageDirectory(thumbnailsDir);
      final path = p.join(base, fileName);
      final parent = File(path).parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      return path;
    } on FileStorageException {
      rethrow;
    } on IOException catch (e) {
      throw _wrap(e, 'saveThumbnail($fileName)');
    } catch (e) {
      throw _wrap(e, 'saveThumbnail');
    }
  }

  @override
  Future<Uint8List> loadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileStorageException(message: 'File not found: $filePath');
      }
      final bytes = await file.readAsBytes();
      return Uint8List.fromList(bytes);
    } on FileStorageException {
      rethrow;
    } on IOException catch (e) {
      throw _wrap(e, 'loadImage($filePath)');
    } catch (e) {
      throw _wrap(e, 'loadImage');
    }
  }

  @override
  Future<Uint8List?> loadPdfBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return Uint8List.fromList(bytes);
    } on IOException catch (e) {
      throw _wrap(e, 'loadPdfBytes($filePath)');
    } catch (e) {
      throw _wrap(e, 'loadPdfBytes');
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } on IOException catch (e) {
      throw _wrap(e, 'deleteFile($filePath)');
    } catch (e) {
      throw _wrap(e, 'deleteFile');
    }
  }

  @override
  Future<void> deleteProcessedImageFiles(ProcessedImage image) async {
    final errors = <String>[];

    try {
      await deleteFile(image.originalPath);
    } catch (e) {
      errors.add('original: ${e.toString()}');
    }

    try {
      await deleteFile(image.processedPath);
    } catch (e) {
      errors.add('processed: ${e.toString()}');
    }

    if (image.thumbnailPath != null) {
      try {
        await deleteFile(image.thumbnailPath!);
      } catch (e) {
        errors.add('thumbnail: ${e.toString()}');
      }
    }

    if (errors.isNotEmpty) {
      throw FileStorageException(
        message: 'Failed to delete some files: ${errors.join(", ")}',
      );
    }
  }
}
