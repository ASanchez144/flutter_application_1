import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'drinks.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE drinks(id INTEGER PRIMARY KEY, name TEXT, volume INTEGER, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
          );
        },
      );
    } catch (e) {
      print("❌ Database Initialization Error: $e");
      rethrow;
    }
  }

  Future<void> addDrink(String name, int volume) async {
    final db = await database;
    await db.insert("drinks", {
      "name": name,
      "volume": volume,
      "timestamp": DateTime.now().toIso8601String(),
    });
    print("✅ Drink Added: $name - $volume ml");
  }

  Future<List<Map<String, dynamic>>> getDrinks(String filter) async {
    final db = await database;
    DateTime now = DateTime.now();
    String query = "SELECT * FROM drinks WHERE timestamp >= ? ORDER BY timestamp DESC";
    List<dynamic> args = [];

    if (filter == "today") {
      args.add(DateTime(now.year, now.month, now.day).toIso8601String());
    } else if (filter == "week") {
      args.add(DateTime(now.year, now.month, now.day - now.weekday).toIso8601String());
    } else if (filter == "month") {
      args.add(DateTime(now.year, now.month, 1).toIso8601String());
    } else if (filter == "year") {
      args.add(DateTime(now.year, 1, 1).toIso8601String());
    } else {
      return await db.query("drinks", orderBy: "timestamp DESC");
    }

    final result = await db.rawQuery(query, args);
    print("📋 Retrieved Drinks: $result");
    return result;
  }
}
