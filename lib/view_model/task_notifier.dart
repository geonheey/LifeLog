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
    loadAllDiaries(); // 모든 다이어리 불러오기 추가
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
        diaries: state.diaries,
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
    await loadDiaries();
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

  Future<void> loadDiaries() async {
    final dateKey = _formatDate(state.selectedDate);
    print("Loading diaries for $dateKey");
    final result = await platform.invokeMethod('getDiary', {'date': dateKey});
    print("Received diary data: $result");
    if (result is List) {
      final diaryList = result.map((e) => Map<String, dynamic>.from(e)).toList();
      print("Parsed diary list: $diaryList");
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, state.selectedDate: diaryList},
      );
    } else {
      print("No diaries found for $dateKey");
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: state.tasks,
        diaries: {...state.diaries, state.selectedDate: []},
      );
    }
  }

  Future<void> addDiary(String diary) async {
    final normalizedDate = _normalizeDate(state.selectedDate);
    final newDiary = {'diary': diary};
    final currentDiaries = List<Map<String, dynamic>>.from(state.diaries[normalizedDate] ?? []);
    currentDiaries.add(newDiary);

    state = TaskModel(
      selectedDate: normalizedDate,
      tasks: state.tasks,
      diaries: {...state.diaries, normalizedDate: currentDiaries},
    );

    await _saveDiaryForDate(normalizedDate, currentDiaries);
  }

  Future<void> _saveDiaryForDate(DateTime date, List<Map<String, dynamic>> diaries) async {
    final dateKey = _formatDate(date);
    print("🔥 Saving diary for $dateKey: $diaries");
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
  Future<void> loadAllDiaries() async {
    final result = await platform.invokeMethod('getAllDiary');
    if (result is Map) {
      final Map<DateTime, List<Map<String, dynamic>>> diariesMap = {};
      result.forEach((key, value) {
        final year = int.parse(key.substring(0, 4));
        final month = int.parse(key.substring(4, 6));
        final day = int.parse(key.substring(6, 8));
        final date = DateTime(year, month, day);
        if (value is List) {
          diariesMap[date] = value.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      });
      state = TaskModel(
        selectedDate: state.selectedDate,
        tasks: state.tasks,
        diaries: diariesMap,
      );
      print("Loaded all diaries: ${state.diaries}");
    }
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
  // Future<void> updateDiary(int index, String newDiary) async {
  //   final updatedDiaries = Map<DateTime, List<Map<String, dynamic>>>.from(state.diaries);
  //   final diaryList = updatedDiaries[state.selectedDate] ?? [];
  //   if (index >= 0 && index < diaryList.length) { // Validate index
  //     diaryList[index] = {'diary': newDiary};
  //     updatedDiaries[state.selectedDate] = diaryList;
  //     state = TaskModel(
  //       tasks: state.tasks,
  //       diaries: updatedDiaries,
  //       selectedDate: state.selectedDate,
  //     );
  //   }
  //   // Add Firebase sync here if needed
  // }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});
