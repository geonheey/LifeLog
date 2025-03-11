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
    loadAllDiaries();
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}"
        "${date.month.toString().padLeft(2, '0')}"
        "${date.day.toString().padLeft(2, '0')}";
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
    await loadDiaries();
  }

  // 모든 할 일 불러오기
  Future<void> loadAllTasks() async {
    try {
      final result = await platform.invokeMethod('getAllTasks');
      final Map<String, dynamic> taskData =
          Map<String, dynamic>.from(result ?? {});
      final updatedTasks = <DateTime, List<Map<String, dynamic>>>{};
      taskData.forEach((key, value) {
        try {
          // Safely parse date string (e.g., "2025-03-11")
          final date =
              DateTime.parse(key); // Use DateTime.parse for full ISO strings
          updatedTasks[date] = (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } catch (e) {
          print('Failed to parse task date "$key": $e');
        }
      });
      state = TaskModel(
        tasks: updatedTasks,
        diaries: state.diaries,
        selectedDate: state.selectedDate,
      );
      print('Loaded tasks: $updatedTasks');
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  // 할 일 불러오기 (해당 날짜의 할 일들)
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

  // 할 일 저장
  Future<void> _saveTasksForDate(
      DateTime date, List<Map<String, dynamic>> tasks) async {
    final dateKey = _formatDate(date);

    await platform.invokeMethod('updateTasks', {
      'date': dateKey,
      'tasks': tasks,
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

  // ----------------------------------------------

  // 모든 일기 불러오기
  Future<void> loadAllDiaries() async {
    try {
      final result = await platform.invokeMethod('getAllDiary');
      final Map<String, dynamic> diaryData =
          Map<String, dynamic>.from(result ?? {});
      final updatedDiaries = <DateTime, List<Map<String, dynamic>>>{};
      diaryData.forEach((key, value) {
        try {
          //  날짜 문자열 파싱 (e.g., "2025-03-11")
          final date = DateTime.parse(key);
          updatedDiaries[date] = (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } catch (e) {
          print('Failed to parse diary date "$key": $e');
        }
      });
      state = TaskModel(
        tasks: state.tasks,
        diaries: updatedDiaries,
        selectedDate: state.selectedDate,
      );
      print('Loaded diaries: $updatedDiaries');
    } catch (e) {
      print('Error loading diaries: $e');
    }
  }

  // 일기 불러오기 (해당 날짜)
  Future<void> loadDiaries() async {
    final dateKey = _formatDate(state.selectedDate);
    final result = await platform.invokeMethod('getDiary', {'date': dateKey});
    if (result is List) {
      final diaryList =
          result.map((e) => Map<String, dynamic>.from(e)).toList();
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, state.selectedDate: diaryList},
      );
    } else {
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, state.selectedDate: []},
      );
    }
  }

  //일기 추가
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

  //일기 저장
  Future<void> _saveDiaryForDate(
      DateTime date, List<Map<String, dynamic>> diaries) async {
    final dateKey = _formatDate(date);
    await platform.invokeMethod('updateDiary', {
      'date': dateKey,
      'diary': diaries,
    });
  }

  // 일기 삭제
  Future<void> removeDiary(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDiary = List<Map<String, dynamic>>.from(
      state.diaries[normalizedDate] ?? [],
    );

    currentDiary.removeAt(index);

    state = TaskModel(
        selectedDate: normalizedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, normalizedDate: currentDiary});

    await _saveTasksForDate(normalizedDate, currentDiary);
  }

  // Future<void> updateTask(int index, String newTask) async {
  //   final updatedTasks = Map<DateTime, List<Map<String, dynamic>>>.from(state.tasks);
  //   final taskList = updatedTasks[state.selectedDate] ?? [];
  //   if (index >= 0 && index < taskList.length) { // Validate index
  //     taskList[index] = {
  //       'task': newTask,
  //       'isDone': taskList[index]['isDone'], // Preserve isDone
  //     };
  //     updatedTasks[state.selectedDate] = taskList;
  //     state = TaskModel(
  //       tasks: updatedTasks,
  //       diaries: state.diaries,
  //       selectedDate: state.selectedDate,
  //     );
  //   }
  //   // Add Firebase sync here if needed
  // }
  //

  // 수정한 일기 업로드
  Future<void> updateDiary(int index, String newDiary) async {
    final updatedDiaries =
        Map<DateTime, List<Map<String, dynamic>>>.from(state.diaries);
    final diaryList = updatedDiaries[state.selectedDate] ?? [];

    if (index >= 0 && index < diaryList.length) {
      diaryList[index] = {'diary': newDiary};
      updatedDiaries[state.selectedDate] = diaryList;

      state = TaskModel(
        tasks: state.tasks,
        diaries: updatedDiaries,
        selectedDate: state.selectedDate,
      );
      await _saveDiaryForDate(state.selectedDate, diaryList);
    } else {
      throw RangeError('Diary index out of bounds');
    }
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});
