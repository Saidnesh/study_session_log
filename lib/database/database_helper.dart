import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/study_session.dart';

/// All SQLite work lives here: create table, insert, page query, update, delete.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _table = 'study_sessions';
  static const int pageSize = 10;

  Future<Database>? _dbFuture;

  Future<Database> get database => _dbFuture ??= _open();

  /// Opens the database file, creating the table on first run.
  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'study_log.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insert(StudySession session) async {
    final db = await database;
    final map = session.toMap()..remove('id'); // let SQLite assign the id
    return db.insert(_table, map);
  }

  Future<int> countAll() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns one page (max 10 rows), newest first.
  /// [page] is 1-based. Uses LIMIT/OFFSET so paging happens inside SQLite.
  Future<List<StudySession>> getPage(int page) async {
    final db = await database;
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC, id DESC',
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
    return rows.map(StudySession.fromMap).toList();
  }

  /// Updates the editable fields of the same row; created_at is kept.
  Future<int> update(StudySession session) async {
    final db = await database;
    return db.update(
      _table,
      {
        'title': session.title,
        'subject': session.subject,
        'duration_minutes': session.durationMinutes,
        'notes': session.notes,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
