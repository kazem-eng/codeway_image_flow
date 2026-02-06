import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:codeway_image_processing/base/services/file_storage_service/file_storage_service.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';

class ProcessedImageSaver {
  ProcessedImageSaver({
    required IFileStorageService fileStorageService,
    required IProcessedImageRepository repository,
    Uuid? uuid,
    int Function()? nowMillis,
  }) : _fileStorageService = fileStorageService,
       _repository = repository,
       _uuid = uuid ?? const Uuid(),
       _nowMillis = nowMillis ?? _defaultNowMillis;

  final IFileStorageService _fileStorageService;
  final IProcessedImageRepository _repository;
  final Uuid _uuid;
  final int Function() _nowMillis;

  Future<ProcessedImage> save({
    required Uint8List originalBytes,
    required Uint8List processedBytes,
    required ProcessingType type,
    required bool isPdf,
    String? metadata,
  }) async {
    final id = _uuid.v4();
    final savedFiles = await _saveFiles(
      id: id,
      originalBytes: originalBytes,
      processedBytes: processedBytes,
      type: type,
      isPdf: isPdf,
    );
    final entity = _createProcessedImageEntity(
      id: id,
      type: type,
      savedFiles: savedFiles,
      processedBytes: processedBytes,
      metadata: metadata,
    );
    await persist(entity);
    return entity;
  }

  Future<void> persist(ProcessedImage entity) async {
    await _repository.init();
    await _repository.add(entity);
  }

  Future<_SavedFiles> _saveFiles({
    required String id,
    required Uint8List originalBytes,
    required Uint8List processedBytes,
    required ProcessingType type,
    required bool isPdf,
  }) async {
    final directory = type.isFace
        ? FileStorageService.facesDir
        : FileStorageService.documentsDir;

    String? originalPath;
    String? processedPath;
    String? thumbnailPath;

    try {
      originalPath = await _fileStorageService.saveProcessedImage(
        originalBytes,
        '$directory/${id}_original.jpg',
      );

      processedPath = isPdf
          ? await _fileStorageService.savePdf(
              processedBytes,
              '$directory/${id}_processed.pdf',
            )
          : await _fileStorageService.saveProcessedImage(
              processedBytes,
              '$directory/${id}_processed.jpg',
            );

      thumbnailPath = await _fileStorageService.saveThumbnail(
        originalBytes,
        '${id}_thumb.jpg',
      );

      return _SavedFiles(
        originalPath: originalPath,
        processedPath: processedPath,
        thumbnailPath: thumbnailPath,
      );
    } catch (e) {
      if (originalPath != null) {
        try {
          await _fileStorageService.deleteFile(originalPath);
        } catch (_) {}
      }
      if (processedPath != null) {
        try {
          await _fileStorageService.deleteFile(processedPath);
        } catch (_) {}
      }
      if (thumbnailPath != null) {
        try {
          await _fileStorageService.deleteFile(thumbnailPath);
        } catch (_) {}
      }
      rethrow;
    }
  }

  ProcessedImage _createProcessedImageEntity({
    required String id,
    required ProcessingType type,
    required _SavedFiles savedFiles,
    required Uint8List processedBytes,
    String? metadata,
  }) {
    return ProcessedImage(
      id: id,
      processingType: type,
      originalPath: savedFiles.originalPath,
      processedPath: savedFiles.processedPath,
      thumbnailPath: savedFiles.thumbnailPath,
      fileSize: processedBytes.length,
      createdAt: _nowMillis(),
      metadata: metadata,
    );
  }

  static int _defaultNowMillis() => DateTime.now().millisecondsSinceEpoch;
}

class _SavedFiles {
  const _SavedFiles({
    required this.originalPath,
    required this.processedPath,
    required this.thumbnailPath,
  });

  final String originalPath;
  final String processedPath;
  final String thumbnailPath;
}
