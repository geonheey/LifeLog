import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task_model.dart';

class TaskNotifier extends StateNotifier<TaskModel> {
  static const platform = MethodChannel('com.example.to_do_list/task_channel');

  TaskNotifier()
    : super(
        TaskModel(selectedDate: _normalizeDate(DateTime.now()), tasks: {}),
      ) {
    loadAllTasks();
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}"
        "${date.month.toString().padLeft(2, '0')}"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadAllTasks() async {
    final result = await platform.invokeMethod('getAllTasks');
    if (result is Map) {
      final Map<DateTime, List<Map<String, dynamic>>> tasksMap = {};
      result.forEach((key, value) {
        final year = int.parse(key.substring(0, 4));
        final month = int.parse(key.substring(4, 6));
        final day = int.parse(key.substring(6, 8));
        final date = DateTime(year, month, day);
        if (value is List) {
          tasksMap[date] =
              value.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      });
      state = TaskModel(selectedDate: state.selectedDate, tasks: tasksMap);
    }
  }

  Future<void> loadTasks() async {
    final dateKey = _formatDate(state.selectedDate);
    final result = await platform.invokeMethod('getTasks', {'date': dateKey});
    if (result is List) {
      final tasksForDate =
          result.map((e) => Map<String, dynamic>.from(e)).toList();
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: {...state.tasks, state.selectedDate: tasksForDate},
      );
    }
  }

  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    state = TaskModel(selectedDate: normalized, tasks: state.tasks);
    await loadTasks();
  }

  Future<void> addTask(String task) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newTask = {'task': task, 'isDone': false};

    final currentTasks = List<Map<String, dynamic>>.from(
      state.tasks[normalizedDate] ?? [],
    );
    currentTasks.add(newTask);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  Future<void> _saveTasksForDate(
    DateTime date,
    List<Map<String, dynamic>> tasks,
  ) async {
    final dateKey = _formatDate(date);

    await platform.invokeMethod('updateTasks', {
      'date': dateKey,
      'tasks': tasks,
    });
  }

  Future<void> toggleTask(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentTasks = List<Map<String, dynamic>>.from(
      state.tasks[normalizedDate] ?? [],
    );

    currentTasks[index]['isDone'] = !currentTasks[index]['isDone'];

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  Future<void> removeTask(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentTasks = List<Map<String, dynamic>>.from(
      state.tasks[normalizedDate] ?? [],
    );

    currentTasks.removeAt(index);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskModel>((
  ref,
) {
  return TaskNotifier();
});
