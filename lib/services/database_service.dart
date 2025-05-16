import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Singleton pattern
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'events.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  // Database operations
  Future<List<Event>> getEvents() async {
    final db = await database;
    final result = await db.query('events', orderBy: 'dueDate ASC');
    return result.map((map) => Event.fromMap(map)).toList();
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'events',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => Event.fromMap(map)).toList();
  }

  Future<Event> getEvent(int id) async {
    final db = await database;
    final result = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Event.fromMap(result.first);
  }

  Future<int> insertEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleEventCompletion(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'events',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get upcoming events for notifications
  Future<List<Event>> getUpcomingEvents() async {
    final db = await database;
    final now = DateTime.now();
    final result = await db.query(
      'events',
      where: 'dueDate > ? AND isCompleted = 0',
      whereArgs: [now.toIso8601String()],
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => Event.fromMap(map)).toList();
  }
}
