// lib/src/services/database_helper.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/doctor.dart';

class DatabaseHelper {
  static const _databaseName = "medinote.db";
  static const _databaseVersion = 1;

  static const doctorTable = 'doctor';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnEmail = 'email';
  static const columnSpecialization = 'specialization';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $doctorTable (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnSpecialization TEXT,
        $columnCreatedAt TEXT,
        $columnUpdatedAt TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed in the future
  }

  // Doctor CRUD operations
  Future<int> insertDoctor(Doctor doctor) async {
    Database db = await database;
    try {
      // Clear existing doctor data (since we only store one doctor)
      await db.delete(doctorTable);

      // Insert new doctor
      return await db.insert(
        doctorTable,
        doctor.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert doctor: $e');
    }
  }

  Future<Doctor?> getCurrentDoctor() async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(doctorTable, limit: 1);

      if (maps.isNotEmpty) {
        return Doctor.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get current doctor: $e');
    }
  }

  Future<int> updateDoctor(Doctor doctor) async {
    Database db = await database;
    try {
      return await db.update(
        doctorTable,
        doctor.toMap(),
        where: '$columnId = ?',
        whereArgs: [doctor.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update doctor: $e');
    }
  }

  Future<int> deleteDoctor(String id) async {
    Database db = await database;
    try {
      return await db.delete(
        doctorTable,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete doctor: $e');
    }
  }

  Future<int> clearAllDoctors() async {
    Database db = await database;
    try {
      return await db.delete(doctorTable);
    } catch (e) {
      throw DatabaseException('Failed to clear doctors: $e');
    }
  }

  Future<bool> isDoctorLoggedIn() async {
    try {
      Doctor? doctor = await getCurrentDoctor();
      return doctor != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> close() async {
    Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
