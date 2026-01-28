import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  final String personId;
  final String task;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;

  Todo({
    String? id,
    required this.personId,
    required this.task,
    this.description,
    this.isCompleted = false,
    this.dueDate,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'task': task,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      personId: map['personId'],
      task: map['task'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
}
