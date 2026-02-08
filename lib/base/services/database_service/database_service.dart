import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'i_database_service.dart';

/// SQLite implementation of [IDatabaseService].
class DatabaseService implements IDatabaseService {
  DatabaseService();

  Database? _db;

  static const String _dbName = 'imageflow.db';
  static const int _dbVersion = 1;

  @override
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
      CREATE TABLE ${IDatabaseService.tableProcessedImages} (
        ${IDatabaseService.columnId} TEXT PRIMARY KEY,
        ${IDatabaseService.columnProcessingType} INTEGER NOT NULL,
        ${IDatabaseService.columnOriginalPath} TEXT NOT NULL,
        ${IDatabaseService.columnProcessedPath} TEXT NOT NULL,
        ${IDatabaseService.columnThumbnailPath} TEXT,
        ${IDatabaseService.columnFileSize} INTEGER,
        ${IDatabaseService.columnCreatedAt} INTEGER NOT NULL,
        ${IDatabaseService.columnMetadata} TEXT
      )
    ''');
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
