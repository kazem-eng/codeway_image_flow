import 'package:sqflite/sqflite.dart';

import 'package:codeway_image_processing/base/services/database_service/i_database_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/models/processed_image/processed_image_data_model.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

import 'i_processed_image_repository.dart';

/// SQLite implementation of processed image repository.
class ProcessedImageRepository implements IProcessedImageRepository {
  ProcessedImageRepository({required IDatabaseService database})
    : _database = database;

  final IDatabaseService _database;

  @override
  Future<void> init() async {
    await _database.database;
  }

  @override
  Future<List<ProcessedImage>> getAll() async {
    final db = await _database.database;
    final maps = await db.query(
      IDatabaseService.tableProcessedImages,
      orderBy: '${IDatabaseService.columnCreatedAt} DESC',
    );
    return maps
        .map((m) => ProcessedImageDataModel.fromMap(m).toEntity())
        .toList();
  }

  @override
  Future<ProcessedImage?> getById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      IDatabaseService.tableProcessedImages,
      where: '${IDatabaseService.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ProcessedImageDataModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<String> add(ProcessedImage image) async {
    final db = await _database.database;
    final model = ProcessedImageDataModel.fromEntity(image);
    await db.insert(
      IDatabaseService.tableProcessedImages,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return image.id;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete(
      IDatabaseService.tableProcessedImages,
      where: '${IDatabaseService.columnId} = ?',
      whereArgs: [id],
    );
  }
}
