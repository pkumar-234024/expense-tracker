import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../models/repayment.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  List<Person> _persons = [];
  List<Expense> _expenses = [];
  List<Debt> _debts = [];
  List<Todo> _todos = [];
  final Map<String, List<Repayment>> _repayments = {};
  Person? _selectedPerson;

  List<Person> get persons => _persons;
  List<Expense> get expenses => _expenses;
  List<Debt> get debts => _debts;
  List<Todo> get todos => _todos;
  Person? get selectedPerson => _selectedPerson;

  List<Repayment> getRepaymentsForDebt(String debtId) {
    return _repayments[debtId] ?? [];
  }

  double getDebtRemainingAmount(Debt debt) {
    final paid = getRepaymentsForDebt(
      debt.id,
    ).fold(0.0, (sum, r) => sum + r.amount);
    return debt.amount - paid;
  }

  Future<void> fetchPersons() async {
    _persons = await _dbHelper.getPersons();
    notifyListeners();
  }

  Future<void> addPerson(String name, String avatar, double budget) async {
    final newPerson = Person(name: name, avatar: avatar, monthlyBudget: budget);
    await _dbHelper.insertPerson(newPerson);
    await fetchPersons();
  }

  Future<void> updatePersonBudget(String id, double budget) async {
    final person = _persons.firstWhere((p) => p.id == id);
    final updatedPerson = Person(
      id: person.id,
      name: person.name,
      avatar: person.avatar,
      monthlyBudget: budget,
    );
    await _dbHelper.insertPerson(updatedPerson);
    if (_selectedPerson?.id == id) {
      _selectedPerson = updatedPerson;
    }
    await fetchPersons();
  }

  Future<void> deletePerson(String id) async {
    await _dbHelper.deletePerson(id);
    await fetchPersons();
  }

  Future<void> selectPerson(Person person) async {
    _selectedPerson = person;
    await fetchExpenses(person.id);
    await fetchDebts(person.id);
    await fetchTodos(person.id);
    notifyListeners();

    await _notificationService.showInstantNotification(
      id: 1,
      title: 'Welcome back, ${person.name}!',
      body: 'Ready to manage your finances?',
    );
  }

  Future<void> fetchExpenses(String personId) async {
    _expenses = await _dbHelper.getExpenses(personId);
    notifyListeners();
  }

  Future<void> addExpense(
    String title,
    double amount,
    String category,
    DateTime date,
  ) async {
    if (_selectedPerson == null) return;

    final newExpense = Expense(
      personId: _selectedPerson!.id,
      title: title,
      amount: amount,
      category: category,
      date: date,
    );

    await _dbHelper.insertExpense(newExpense);
    await fetchExpenses(_selectedPerson!.id);
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense);
    if (_selectedPerson != null) {
      await fetchExpenses(_selectedPerson!.id);
    }
  }

  Future<void> removeExpense(String id) async {
    await _dbHelper.deleteExpense(id);
    if (_selectedPerson != null) {
      await fetchExpenses(_selectedPerson!.id);
    }
  }

  // Todo methods
  Future<void> fetchTodos(String personId) async {
    _todos = await _dbHelper.getTodos(personId);
    notifyListeners();
  }

  Future<void> addTodo(
    String task,
    String? description,
    DateTime? dueDate,
  ) async {
    if (_selectedPerson == null) return;
    final todo = Todo(
      personId: _selectedPerson!.id,
      task: task,
      description: description,
      dueDate: dueDate,
    );
    await _dbHelper.insertTodo(todo);
    await fetchTodos(_selectedPerson!.id);

    if (dueDate != null) {
      // Schedule morning reminder on due date
      final reminderTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9, // 9 AM
      );

      if (reminderTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: todo.id.hashCode,
          title: 'Task Reminder',
          body: 'Pending: $task',
          scheduledDate: reminderTime,
        );
      }
    }
  }

  Future<void> toggleTodo(String id, bool isCompleted) async {
    await _dbHelper.updateTodoStatus(id, isCompleted);
    if (isCompleted) {
      await _notificationService.cancelNotification(id: id.hashCode);
    }
    if (_selectedPerson != null) {
      await fetchTodos(_selectedPerson!.id);
    }
  }

  Future<void> removeTodo(String id) async {
    await _dbHelper.deleteTodo(id);
    await _notificationService.cancelNotification(id: id.hashCode);
    if (_selectedPerson != null) {
      await fetchTodos(_selectedPerson!.id);
    }
  }

  // Debt & Repayment methods
  Future<void> fetchDebts(String personId) async {
    _debts = await _dbHelper.getDebts(personId);
    for (var debt in _debts) {
      await fetchRepayments(debt.id);
    }
    notifyListeners();
  }

  Future<void> addDebt(
    String borrowerName,
    double amount,
    DateTime date,
    String? notes,
  ) async {
    if (_selectedPerson == null) return;
    final debt = Debt(
      personId: _selectedPerson!.id,
      borrowerName: borrowerName,
      amount: amount,
      date: date,
      notes: notes,
    );
    await _dbHelper.insertDebt(debt);
    await fetchDebts(_selectedPerson!.id);
  }

  Future<void> deleteDebt(String id) async {
    await _dbHelper.deleteDebt(id);
    if (_selectedPerson != null) {
      await fetchDebts(_selectedPerson!.id);
    }
  }

  Future<void> fetchRepayments(String debtId) async {
    _repayments[debtId] = await _dbHelper.getRepayments(debtId);
    notifyListeners();
  }

  Future<void> addRepayment(
    String debtId,
    double amount,
    DateTime date,
    String? notes,
  ) async {
    final repayment = Repayment(
      debtId: debtId,
      amount: amount,
      date: date,
      notes: notes,
    );
    await _dbHelper.insertRepayment(repayment);
    await fetchRepayments(debtId);

    // Check if debt is completed
    final debt = _debts.firstWhere((d) => d.id == debtId);
    if (getDebtRemainingAmount(debt) <= 0) {
      await _dbHelper.updateDebtCompletion(debtId, true);
      if (_selectedPerson != null) {
        await fetchDebts(_selectedPerson!.id);
      }
    }
  }

  double get totalForSelectedPerson {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get monthlyBudget => _selectedPerson?.monthlyBudget ?? 10000.0;

  double get remainingBudget {
    return monthlyBudget - totalForSelectedPerson;
  }

  void logout() {
    _selectedPerson = null;
    _expenses = [];
    _debts = [];
    _repayments.clear();
    notifyListeners();
  }
}
