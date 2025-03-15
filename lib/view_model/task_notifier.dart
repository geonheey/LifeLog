import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task_model.dart';

class TaskNotifier extends StateNotifier<TaskModel> {
  static const platform = MethodChannel('com.example.to_do_list/task_channel');

  TaskNotifier() : super(TaskModel(selectedDate: _normalizeDate(DateTime.now()), tasks: {}, diaries: {}, days: {})) {
    _restoreState();
  }

  static DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) => "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";

  // 상태 복구 메서드
  Future<void> _restoreState() async {
    await loadAllTasks();
    await loadAllDiaries();
    await loadAllDays();
    await loadTasks();
    await loadDiaries();
    await loadDay();
    print('State restored for selectedDate: ${state.selectedDate}');
  }
  // 날짜 설정
  Future<void> setSelectedDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    state = state.copyWith(selectedDate: normalized);
    await loadTasks();
    await loadDiaries();
    await loadAllDays();
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
          final date = DateTime.parse(key);
          updatedTasks[date] = (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } catch (e) {
          print('Failed to parse task date "$key": $e');
        }
      });

      state = state.copyWith(tasks: updatedTasks);
      print('Loaded tasks: $updatedTasks');
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  // 할 일 불러오기 (해당 날짜)
  Future<void> loadTasks() async {
    final dateKey = _formatDate(state.selectedDate);
    try {
      final result = await platform.invokeMethod('getTasks', {'date': dateKey});
      if (result is List) {
        final tasksForDate =
        result.map((e) => Map<String, dynamic>.from(e)).toList();
        state = state.copyWith(
          tasks: {...state.tasks, state.selectedDate: tasksForDate},
        );
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  // 할 일 추가
  Future<void> addTask(String task) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newTask = {'task': task, 'isDone': false};
    final currentTasks =
    List<Map<String, dynamic>>.from(state.tasks[normalizedDate] ?? []);
    currentTasks.add(newTask);

    state = state.copyWith(
      tasks: {...state.tasks, normalizedDate: currentTasks},
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

    state = state.copyWith(
      tasks: {...state.tasks, normalizedDate: currentTasks},
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  // 할 일 삭제
  Future<void> removeTask(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentTasks =
    List<Map<String, dynamic>>.from(state.tasks[normalizedDate] ?? []);
    currentTasks.removeAt(index);

    state = state.copyWith(
      tasks: {...state.tasks, normalizedDate: currentTasks},
    );

    await _saveTasksForDate(normalizedDate, currentTasks);
  }

  // 모든 일기 불러오기
  Future<void> loadAllDiaries() async {
    try {
      final result = await platform.invokeMethod('getAllDiaries'); // 메서드 이름 수정
      final Map<String, dynamic> diaryData =
      Map<String, dynamic>.from(result ?? {});
      final updatedDiaries = <DateTime, List<Map<String, dynamic>>>{};

      diaryData.forEach((key, value) {
        try {
          final date = DateTime.parse(key);
          updatedDiaries[date] = (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } catch (e) {
          print('Failed to parse diary date "$key": $e');
        }
      });

      state = state.copyWith(diaries: updatedDiaries);
      print('Loaded diaries: $updatedDiaries');
    } catch (e) {
      print('Error loading diaries: $e');
    }
  }

  // 일기 불러오기 (해당 날짜)
  Future<void> loadDiaries() async {
    final dateKey = _formatDate(state.selectedDate);
    try {
      final result = await platform.invokeMethod('getDiaries', {'date': dateKey});
      if (result is List) {
        final diaryList =
        result.map((e) => Map<String, dynamic>.from(e)).toList();
        state = state.copyWith(
          diaries: {...state.diaries, state.selectedDate: diaryList},
        );
      }
    } catch (e) {
      print('Error loading diaries: $e');
    }
  }

  // 일기 추가
  Future<void> addDiary(String diary) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newDiary = {'diary': diary};
    final currentDiaries =
    List<Map<String, dynamic>>.from(state.diaries[normalizedDate] ?? []);
    currentDiaries.add(newDiary);

    state = state.copyWith(
      diaries: {...state.diaries, normalizedDate: currentDiaries},
    );

    await _saveDiaryForDate(normalizedDate, currentDiaries);
  }

  // 일기 저장
  Future<void> _saveDiaryForDate(
      DateTime date, List<Map<String, dynamic>> diaries) async {
    final dateKey = _formatDate(date);
    await platform.invokeMethod('updateDiaries', {
      'date': dateKey,
      'diaries': diaries,
    });
  }

  // 일기 삭제
  Future<void> removeDiary(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDiaries =
    List<Map<String, dynamic>>.from(state.diaries[normalizedDate] ?? []);
    currentDiaries.removeAt(index);

    state = state.copyWith(
      diaries: {...state.diaries, normalizedDate: currentDiaries},
    );

    await _saveDiaryForDate(normalizedDate, currentDiaries);
  }

  // 일기 수정
  Future<void> updateDiary(int index, String newDiary) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDiaries =
    List<Map<String, dynamic>>.from(state.diaries[normalizedDate] ?? []);

    if (index >= 0 && index < currentDiaries.length) {
      currentDiaries[index] = {'diary': newDiary};
      state = state.copyWith(
        diaries: {...state.diaries, normalizedDate: currentDiaries},
      );
      await _saveDiaryForDate(normalizedDate, currentDiaries);
    } else {
      throw RangeError('Diary index out of bounds');
    }
  }
  /////////////////////////
/// 모든 'day' 불러오기
  Future<void> loadAllDays() async {
    try {
      final result = await platform.invokeMethod('getAllDays');
      final Map<String, dynamic> dayData =
      Map<String, dynamic>.from(result ?? {});
      final updatedDays = <DateTime, List<Map<String, dynamic>>>{};

      dayData.forEach((key, value) {
        try {
          final date = DateTime.parse(key);
          updatedDays[date] = (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } catch (e) {
          print('Failed to parse day date "$key": $e');
        }
      });

      state = state.copyWith(days: updatedDays);
      print('Loaded days: $updatedDays');
    } catch (e) {
      print('Error loading days: $e');
    }
  }

  // 날짜별 'day' 불러오기
  Future<void> loadDay() async {
    final dateKey = _formatDate(state.selectedDate);
    try {
      final result = await platform.invokeMethod('getDays', {'date': dateKey});
      if (result is List) {
        final dayList = result.map((e) => Map<String, dynamic>.from(e)).toList();
        state = state.copyWith(
          days: {...state.days, state.selectedDate: dayList},
        );
      }
    } catch (e) {
      print('Error loading day: $e');
    }
  }

  // 날짜별 'day' 추가
  Future<void> addDay(String day) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newDay = {'day': day};
    final currentDays = List<Map<String, dynamic>>.from(state.days[normalizedDate] ?? []);
    currentDays.add(newDay);

    state = state.copyWith(
      days: {...state.days, normalizedDate: currentDays},
    );

    await _saveDayForDate(normalizedDate, currentDays);
  }

  // 날짜별 'day' 저장
  Future<void> _saveDayForDate(DateTime date, List<Map<String, dynamic>> days) async {
    final dateKey = _formatDate(date);
    await platform.invokeMethod('updateDays', {
      'date': dateKey,
      'days': days,
    });
  }

  // 날짜별 'day' 삭제
  Future<void> removeDay(int index) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDays = List<Map<String, dynamic>>.from(state.days[normalizedDate] ?? []);
    currentDays.removeAt(index);

    state = state.copyWith(
      days: {...state.days, normalizedDate: currentDays},
    );

    await _saveDayForDate(normalizedDate, currentDays);
  }

  // 날짜별 'day' 수정
  Future<void> updateDays(int index, String day) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final currentDays = List<Map<String, dynamic>>.from(state.days[normalizedDate] ?? []);

    if (index >= 0 && index < currentDays.length) {
      currentDays[index] = {'day': day};
      state = state.copyWith(
        days: {...state.days, normalizedDate: currentDays},
      );
      await _saveDayForDate(normalizedDate, currentDays);
    } else {
      throw RangeError('Day index out of bounds');
    }
  }
}

final taskNotifierProvider =
StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});