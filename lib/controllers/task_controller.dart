import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskController extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Task> tasks = [];

  Future<void> loadTasks() async {
    try {
      final response = await supabase.from('tasks').select().order('due_date', ascending: true);
      tasks = response.map((data) => Task.fromMap(data)).toList();
      notifyListeners(); 
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> addTask(String title, String subject, String difficulty, DateTime? dueDate) async {
    try {
      // ไม่ส่ง id ไป เพื่อให้ Supabase สร้าง UUID ให้เองอัตโนมัติ
      await supabase.from('tasks').insert({
        'title': title, 
        'subject': subject, 
        'difficulty': difficulty,
        'due_date': dueDate?.toIso8601String(),
        'is_done': false,
        'total_seconds': 0
      });
      await loadTasks();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> editTask(String id, String newTitle, String newSubject, String newDifficulty, DateTime? newDueDate) async {
    try {
      await supabase.from('tasks').update({
        'title': newTitle,
        'subject': newSubject,
        'difficulty': newDifficulty,
        'due_date': newDueDate?.toIso8601String()
      }).eq('id', id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error editing task: $e');
    }
  }

  Future<void> toggleDone(int index) async {
    try {
      final task = tasks[index];
      await supabase.from('tasks').update({'is_done': !task.isDone}).eq('id', task.id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(int index) async {
    try {
      await supabase.from('tasks').delete().eq('id', tasks[index].id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> addTimeSpent(String id, int seconds) async {
    try {
      final task = tasks.firstWhere((t) => t.id == id);
      final newTotal = task.totalSeconds + seconds;
      await supabase.from('tasks').update({'total_seconds': newTotal}).eq('id', id);
      await loadTasks();
    } catch (e) {
      debugPrint('Error adding time: $e');
    }
  }
}

final taskController = TaskController();