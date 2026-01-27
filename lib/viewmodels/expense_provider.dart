import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Person> _persons = [];
  List<Expense> _expenses = [];
  Person? _selectedPerson;

  List<Person> get persons => _persons;
  List<Expense> get expenses => _expenses;
  Person? get selectedPerson => _selectedPerson;

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
    notifyListeners();
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
    notifyListeners();
  }
}
