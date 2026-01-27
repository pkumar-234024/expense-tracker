import 'package:uuid/uuid.dart';

class Person {
  final String id;
  final String name;
  final String avatar; // This will be an emoji or icon name

  Person({String? id, required this.name, this.avatar = '👤'})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(id: map['id'], name: map['name'], avatar: map['avatar']);
  }
}
