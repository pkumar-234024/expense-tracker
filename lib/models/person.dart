import 'package:uuid/uuid.dart';

class Person {
  final String id;
  final String name;
  final String avatar;
  final double monthlyBudget;

  Person({
    String? id,
    required this.name,
    this.avatar = '👤',
    this.monthlyBudget = 10000.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      name: map['name'],
      avatar: map['avatar'],
      monthlyBudget: map['monthlyBudget']?.toDouble() ?? 10000.0,
    );
  }
}
