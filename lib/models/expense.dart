import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String personId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    String? id,
    required this.personId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      personId: map['personId'],
      title: map['title'],
      amount: map['amount'] as double,
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
