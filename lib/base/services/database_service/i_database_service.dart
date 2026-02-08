import 'package:sqflite/sqflite.dart';

/// SQLite database service for the app.
abstract class IDatabaseService {
  static const String tableProcessedImages = 'processed_images';
  static const String columnId = 'id';
  static const String columnProcessingType = 'processing_type';
  static const String columnOriginalPath = 'original_path';
  static const String columnProcessedPath = 'processed_path';
  static const String columnThumbnailPath = 'thumbnail_path';
  static const String columnFileSize = 'file_size';
  static const String columnCreatedAt = 'created_at';
  static const String columnMetadata = 'metadata';

  Future<Database> get database;
  Future<void> close();
}
