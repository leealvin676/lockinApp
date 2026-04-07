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


  Future<Map<String, int>> getStats() async {
    final dbClient = await db;

    final result = await dbClient.rawQuery('''
      SELECT 
        COUNT(*) as totalWorkouts,
        SUM(duration) as totalMinutes
      FROM workouts
    ''');

    final workouts = result.first['totalWorkouts'] as int? ?? 0;
    final minutes = result.first['totalMinutes'] as int? ?? 0;

    return {
      'workouts': workouts,
      'calories': minutes * 5,
    };
  }

  Future<int> getStreak() async {
    final data = await getWorkouts();

    if (data.isEmpty) return 0;

    final uniqueDates = data
        .map((w) => DateTime.tryParse(w['date'] ?? ''))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList();

    uniqueDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; i < uniqueDates.length; i++) {
      final expected = DateTime(today.year, today.month, today.day - i);

      if (uniqueDates.any((d) =>
      d.year == expected.year &&
          d.month == expected.month &&
          d.day == expected.day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}