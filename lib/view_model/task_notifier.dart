import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task_model.dart';

class TaskNotifier extends StateNotifier<TaskModel> {
  static const platform = MethodChannel('com.example.to_do_list/task_channel');

  TaskNotifier()
      : super(
          TaskModel(
              selectedDate: _normalizeDate(DateTime.now()),
              tasks: {},
              diaries: {}),
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

  // 모든 할 일 불러오기
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
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: tasksMap,
        diaries: state.diaries, // diaries는 기존 상태 유지
      );
    }
  }

  // 할 일 불러오기
  Future<void> loadTasks() async {
    final dateKey = _formatDate(state.selectedDate);
    final result = await platform.invokeMethod('getTasks', {'date': dateKey});
    if (result is List) {
      final tasksForDate =
          result.map((e) => Map<String, dynamic>.from(e)).toList();
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: {...state.tasks, state.selectedDate: tasksForDate},
        diaries: state.diaries,
      );
    }
  }

  // 날짜 설정
  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    state = TaskModel(
      selectedDate: normalized,
      tasks: state.tasks,
      diaries: state.diaries,
    );
    await loadTasks();
  }

  // 할 일 추가
  Future<void> addTask(String task) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newTask = {'task': task, 'isDone': false};

    final currentTasks =
        List<Map<String, dynamic>>.from(state.tasks[normalizedDate] ?? []);
    currentTasks.add(newTask);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
      diaries: state.diaries,
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  // 일기 추가
  Future<void> addDiary(String diary) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newDiary = {'diary': diary};

    final currentDiaries =
        List<Map<String, dynamic>>.from(state.diaries[normalizedDate] ?? []);
    currentDiaries.add(newDiary);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: state.tasks,
      diaries: {...state.diaries, normalizedDate: currentDiaries},
    );

    await _saveDiaryForDate(normalizedDate, currentDiaries);
  }

  // 할 일 저장
  Future<void> _saveTasksForDate(
      DateTime date, List<Map<String, dynamic>> tasks) async {
    final dateKey = _formatDate(date);

    await platform.invokeMethod('updateTasks', {
      'date': dateKey,
      'tasks': tasks,
    });
  }

  // 일기 저장
  Future<void> _saveDiaryForDate(
      DateTime date, List<Map<String, dynamic>> diaries) async {
    final dateKey = _formatDate(date);

    await platform.invokeMethod('updateDiary', {
      'date': dateKey,
      'diary': diaries,
    });
  }

  // 할 일 완료 상태 토글
  Future<void> toggleTask(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentTasks =
        List<Map<String, dynamic>>.from(state.tasks[normalizedDate] ?? []);

    currentTasks[index]['isDone'] = !currentTasks[index]['isDone'];

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
      diaries: state.diaries,
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  // 할 일 삭제
  Future<void> removeTask(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentTasks = List<Map<String, dynamic>>.from(
      state.tasks[normalizedDate] ?? [],
    );

    currentTasks.removeAt(index);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: {...state.tasks, normalizedDate: currentTasks},
      diaries: state.diaries,
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  // 일기 삭제
  Future<void> removeDiary(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDiary = List<Map<String, dynamic>>.from(
      state.tasks[normalizedDate] ?? [],
    );

    currentDiary.removeAt(index);

    state = TaskModel(
        selectedDate: normalizedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, normalizedDate: currentDiary});

    await _saveTasksForDate(normalizedDate, currentDiary);
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});
