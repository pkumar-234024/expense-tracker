import 'package:uuid/uuid.dart';

class Repayment {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? notes;

  Repayment({
    String? id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Repayment.fromMap(Map<String, dynamic> map) {
    return Repayment(
      id: map['id'],
      debtId: map['debtId'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}
