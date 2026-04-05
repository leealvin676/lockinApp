import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'workout.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            duration INTEGER,
            sets INTEGER,
            reps INTEGER,
            notes TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  // ➕ INSERT
  Future<void> insertWorkout(Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert('workouts', data);
  }

  // 📥 GET
  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final dbClient = await db;
    return await dbClient.query('workouts', orderBy: 'id DESC');
  }

  // ❌ DELETE
  Future<void> deleteWorkout(int id) async {
    final dbClient = await db;
    await dbClient.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ✏️ UPDATE
  Future<void> updateWorkout(int id, Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.update(
      'workouts',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}