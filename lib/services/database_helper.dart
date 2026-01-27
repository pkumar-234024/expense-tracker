import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE persons ADD COLUMN monthlyBudget REAL DEFAULT 10000.0',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE persons(
        id TEXT PRIMARY KEY,
        name TEXT,
        avatar TEXT,
        monthlyBudget REAL DEFAULT 10000.0
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        personId TEXT,
        title TEXT,
        amount REAL,
        category TEXT,
        date TEXT,
        FOREIGN KEY (personId) REFERENCES persons (id) ON DELETE CASCADE
      )
    ''');
  }

  // Person operations
  Future<void> insertPerson(Person person) async {
    final db = await database;
    await db.insert(
      'persons',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Person>> getPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('persons');
    return List.generate(maps.length, (i) => Person.fromMap(maps[i]));
  }

  Future<void> deletePerson(String id) async {
    final db = await database;
    await db.delete('persons', where: 'id = ?', whereArgs: [id]);
  }

  // Expense operations
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses(String personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'personId = ?',
      whereArgs: [personId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpenses(String personId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE personId = ?',
      [personId],
    );
    return result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }
}
