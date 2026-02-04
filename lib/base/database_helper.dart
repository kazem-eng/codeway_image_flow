import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for the app.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  static const String _dbName = 'imageflow.db';
  static const int _dbVersion = 1;

  static const String tableProcessedImages = 'processed_images';
  static const String columnId = 'id';
  static const String columnProcessingType = 'processing_type';
  static const String columnOriginalPath = 'original_path';
  static const String columnProcessedPath = 'processed_path';
  static const String columnThumbnailPath = 'thumbnail_path';
  static const String columnFileSize = 'file_size';
  static const String columnCreatedAt = 'created_at';
  static const String columnMetadata = 'metadata';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProcessedImages (
        $columnId TEXT PRIMARY KEY,
        $columnProcessingType INTEGER NOT NULL,
        $columnOriginalPath TEXT NOT NULL,
        $columnProcessedPath TEXT NOT NULL,
        $columnThumbnailPath TEXT,
        $columnFileSize INTEGER,
        $columnCreatedAt INTEGER NOT NULL,
        $columnMetadata TEXT
      )
    ''');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
