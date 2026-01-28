import 'package:uuid/uuid.dart';

class Debt {
  final String id;
  final String personId;
  final String borrowerName;
  final double amount;
  final DateTime date;
  final String? notes;
  final bool isCompleted;

  Debt({
    String? id,
    required this.personId,
    required this.borrowerName,
    required this.amount,
    required this.date,
    this.notes,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'borrowerName': borrowerName,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      personId: map['personId'],
      borrowerName: map['borrowerName'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
