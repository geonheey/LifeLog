import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task_model.dart';

class TaskNotifier extends StateNotifier<TaskModel> {
  TaskNotifier()
      : super(TaskModel(selectedDate: _normalizeDate(DateTime.now()), tasks: {}));

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void setSelectedDate(DateTime date) {
    state = TaskModel(
      selectedDate: _normalizeDate(date),
      tasks: state.tasks,
    );
  }

  void addTask(String task) {
    final selectedDateKey = _normalizeDate(state.selectedDate);
    final newTask = {'task': task, 'isDone': false};

    final currentTasks = List<Map<String, dynamic>>.from(state.tasks[selectedDateKey] ?? []);
    currentTasks.add(newTask);

    state = TaskModel(
      selectedDate: selectedDateKey,
      tasks: {
        ...state.tasks,
        selectedDateKey: currentTasks,
      },
    );
  }

  void toggleTask(int index) {
    final selectedDateKey = _normalizeDate(state.selectedDate);
    final currentTasks = List<Map<String, dynamic>>.from(state.tasks[selectedDateKey] ?? []);

    currentTasks[index]['isDone'] = !currentTasks[index]['isDone'];

    state = TaskModel(
      selectedDate: selectedDateKey,
      tasks: {
        ...state.tasks,
        selectedDateKey: currentTasks,
      },
    );
  }

  void removeTask(int index) {
    final selectedDateKey = _normalizeDate(state.selectedDate);
    final currentTasks = List<Map<String, dynamic>>.from(state.tasks[selectedDateKey] ?? []);

    currentTasks.removeAt(index);

    state = TaskModel(
      selectedDate: selectedDateKey,
      tasks: {
        ...state.tasks,
        selectedDateKey: currentTasks,
      },
    );
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});
