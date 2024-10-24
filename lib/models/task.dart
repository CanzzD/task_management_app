import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  bool status;

  factory Task.create({
    required String? title,
    required String? description,
  }) =>
      Task(
        id: const Uuid().v1(),
        title: title ?? "",
        description: description ?? "",
        status: false,
      );

  // JSON'dan Task oluşturmak için bir metot
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] == 'true',
    );
  }

  Task copyWith({String? id, String? title, String? description, bool? status}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  // Task'ı JSON'a dönüştürmek için bir metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
