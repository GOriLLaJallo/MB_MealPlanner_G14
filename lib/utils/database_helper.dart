import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static const _databaseName = "meal_planner.db";
  static const _databaseVersion = 2;

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = _databaseName;
    if (!kIsWeb) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE meal_plans ADD COLUMN isConsumed INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future _onCreate(Database db, int version) async {
    // Recipes Table
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        prepTimeMinutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        servings INTEGER NOT NULL,
        instructions TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Pantry Items Table
    await db.execute('''
      CREATE TABLE pantry_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        expiryDate TEXT,
        notes TEXT
      )
    ''');

    // Meal Plans Table
    await db.execute('''
      CREATE TABLE meal_plans (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        recipeId TEXT NOT NULL,
        isConsumed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Shopping List Table
    await db.execute('''
      CREATE TABLE shopping_list (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        isPurchased INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Generic CRUD helpers
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row, String idColumnName, String id) async {
    Database db = await instance.database;
    return await db.update(table, row, where: '$idColumnName = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String idColumnName, String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$idColumnName = ?', whereArgs: [id]);
  }
  
  Future<void> clearTable(String table) async {
    Database db = await instance.database;
    await db.delete(table);
  }
}
