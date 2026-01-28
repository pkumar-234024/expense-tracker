import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../models/repayment.dart';
import '../models/todo.dart';

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
      version: 5,
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
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE debts(
          id TEXT PRIMARY KEY,
          personId TEXT,
          borrowerName TEXT,
          amount REAL,
          date TEXT,
          notes TEXT,
          isCompleted INTEGER DEFAULT 0,
          FOREIGN KEY (personId) REFERENCES persons (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE repayments(
          id TEXT PRIMARY KEY,
          debtId TEXT,
          amount REAL,
          date TEXT,
          notes TEXT,
          FOREIGN KEY (debtId) REFERENCES debts (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE todos(
          id TEXT PRIMARY KEY,
          personId TEXT,
          task TEXT,
          isCompleted INTEGER DEFAULT 0,
          dueDate TEXT,
          FOREIGN KEY (personId) REFERENCES persons (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      // Add description column to todos table
      await db.execute('ALTER TABLE todos ADD COLUMN description TEXT');
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
    await db.execute('''
      CREATE TABLE debts(
        id TEXT PRIMARY KEY,
        personId TEXT,
        borrowerName TEXT,
        amount REAL,
        date TEXT,
        notes TEXT,
        isCompleted INTEGER DEFAULT 0,
        FOREIGN KEY (personId) REFERENCES persons (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE repayments(
        id TEXT PRIMARY KEY,
        debtId TEXT,
        amount REAL,
        date TEXT,
        notes TEXT,
        FOREIGN KEY (debtId) REFERENCES debts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        personId TEXT,
        task TEXT,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        dueDate TEXT,
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

  // Debt operations
  Future<void> insertDebt(Debt debt) async {
    final db = await database;
    await db.insert(
      'debts',
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Debt>> getDebts(String personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'personId = ?',
      whereArgs: [personId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<void> deleteDebt(String id) async {
    final db = await database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDebtCompletion(String id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'debts',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Repayment operations
  Future<void> insertRepayment(Repayment repayment) async {
    final db = await database;
    await db.insert(
      'repayments',
      repayment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Repayment>> getRepayments(String debtId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'repayments',
      where: 'debtId = ?',
      whereArgs: [debtId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Repayment.fromMap(maps[i]));
  }

  Future<void> deleteRepayment(String id) async {
    final db = await database;
    await db.delete('repayments', where: 'id = ?', whereArgs: [id]);
  }

  // Todo operations
  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos(String personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'personId = ?',
      whereArgs: [personId],
      orderBy: 'isCompleted ASC, dueDate ASC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<void> updateTodoStatus(String id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'todos',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
