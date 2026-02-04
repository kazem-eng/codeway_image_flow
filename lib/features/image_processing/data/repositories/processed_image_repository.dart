import 'package:sqflite/sqflite.dart';

import 'package:codeway_image_processing/base/database_helper.dart';
import 'package:codeway_image_processing/features/image_processing/data/models/processed_image/processed_image_data_model.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

import 'i_processed_image_repository.dart';

/// SQLite implementation of processed image repository.
class ProcessedImageRepository implements IProcessedImageRepository {
  ProcessedImageRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  @override
  Future<void> init() async {
    await _dbHelper.database;
  }

  @override
  Future<List<ProcessedImage>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProcessedImages,
      orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
    );
    return maps
        .map((m) => ProcessedImageDataModel.fromMap(m).toEntity())
        .toList();
  }

  @override
  Future<ProcessedImage?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableProcessedImages,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ProcessedImageDataModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<String> add(ProcessedImage image) async {
    final db = await _dbHelper.database;
    final model = ProcessedImageDataModel.fromEntity(image);
    await db.insert(
      DatabaseHelper.tableProcessedImages,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return image.id;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableProcessedImages,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }
}
