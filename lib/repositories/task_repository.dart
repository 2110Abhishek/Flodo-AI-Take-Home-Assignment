import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> saveTasks(List<Task> tasks);
}

class LocalTaskRepository implements TaskRepository {
  static const String _tasksKey = 'tasks_v2';

  @override
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(tasksJson);
      return decodedList.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }
}
