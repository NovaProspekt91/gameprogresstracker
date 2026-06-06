import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game.dart';

class DatabaseHelper {
  static const _databaseName = 'game_progress.db';
  static const _databaseVersion = 1;
  static const table = 'games';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnPlatform = 'platform';
  static const columnStatus = 'status';
  static const columnHoursPlayed = 'hoursPlayed';
  static const columnCompletionPercent = 'completionPercent';
  static const columnRating = 'rating';
  static const columnNotes = 'notes';
  static const columnCreatedAt = 'createdAt';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnPlatform TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnHoursPlayed REAL NOT NULL DEFAULT 0.0,
        $columnCompletionPercent INTEGER NOT NULL DEFAULT 0,
        $columnRating REAL NOT NULL DEFAULT 0.0,
        $columnNotes TEXT NOT NULL DEFAULT '',
        $columnCreatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertGame(Game game) async {
    final db = await database;
    return await db.insert(
      table,
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return await db.update(
      table,
      game.toMap(),
      where: '$columnId = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final maps = await db.query(
      table,
      orderBy: '$columnCreatedAt DESC',
    );
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> searchGames(String query) async {
    final db = await database;
    final maps = await db.query(
      table,
      where: '$columnTitle LIKE ? OR $columnPlatform LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '$columnCreatedAt DESC',
    );
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<Game?> getGameById(int id) async {
    final db = await database;
    final maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Game.fromMap(maps.first);
  }
}
