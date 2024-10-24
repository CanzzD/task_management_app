import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:task_management_app/models/task.dart';

class HybridDataStore {
  static const boxName = 'taskBox';
  final String apiUrl = 'https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks';
  final Box<Task> hiveBox = Hive.box<Task>(boxName);



  Future<List<Task>> getAllTasks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // API'den gelen görevleri al
        List<dynamic> data = jsonDecode(response.body);
        List<Task> tasks = data.map((json) => Task.fromJson(json)).toList();

        // Hive'daki görevleri güncelle
        for (var task in tasks) {
          await hiveBox.put(task.id, task); // Eğer task.id mevcutsa güncellenir
        }

        return tasks; // Sadece API'den gelen görevleri döndür
      } else {
        throw Exception('Failed to load tasks from API');
      }
    } catch (e) {
      print("API hatası: $e");

      // Eğer internet yoksa Hive'daki görevleri döndür
      return hiveBox.values.toList();
    }
  }




  // Yeni bir görev ekle (API + Hive)
  Future<void> addTask({required Task task}) async {
    try {
      // API'ye yeni görev ekle
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'status': task.status.toString(),
        }),
      );

      if (response.statusCode == 201) {
        // API başarılıysa dönen görevden yeni ID'yi al
        final newTask = Task.fromJson(jsonDecode(response.body));
        // Hive'a yeni görevi ekle
        await hiveBox.put(newTask.id, newTask);
      } else {
        throw Exception('Failed to add task to API');
      }
    } catch (e) {
      // Çevrimdışı modda Hive'a doğrudan ekle
      await hiveBox.put(task.id, task);
    }
  }


  // Mevcut bir görevi güncelle (API + Hive)
  Future<void> updateTask({required Task task}) async {
    try {
      // API'de güncelle
      final response = await http.put(
        Uri.parse('https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'status': task.status,
        }),
      );

      if (response.statusCode == 200) {
        // Hive'da güncelle
        await task.save();
      } else {
        throw Exception('Failed to update task on API');
      }
    } catch (e) {
      // Çevrimdışı modda Hive'da doğrudan güncelle
      await task.save();
    }
  }

  // Görevi sil (API + Hive)
  Future<void> deleteTask({required String id}) async {
    try {
      // API'den sil
      final response = await http.delete(Uri.parse('https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks/$id'));

      if (response.statusCode == 200) {
        // Hive'dan sil
        await hiveBox.delete(id);
      } else {
        throw Exception('Failed to delete task from API');
      }
    } catch (e) {
      // Çevrimdışı modda sadece Hive'dan sil
      await hiveBox.delete(id);
    }
  }
  Future<List<Task>> getTasksFromHive() async {
    // Hive'dan görevleri almak için
    List<Task> tasks = hiveBox.values.toList();
    return tasks;
  }

  // Hive'daki tüm görevler için listenable (değişiklikleri dinlemek için)
  ValueListenable<Box<Task>> listenToTask() => hiveBox.listenable();
}
