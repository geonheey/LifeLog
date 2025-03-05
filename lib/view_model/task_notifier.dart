import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/task_model.dart';

class TaskNotifier extends StateNotifier<TaskModel> {
  TaskNotifier() : super(TaskModel(selectedDate: DateTime.now(), tasks: {}));

  void setSelectedDate(DateTime date) {
    state = TaskModel(selectedDate: DateTime(date.year, date.month, date.day), tasks: state.tasks);
  }

  void addTask(String task) {
    final newTasks = List<Map<String, dynamic>>.from(state.currentTasks)
      ..add({'task': task, 'isDone': false});
    state = TaskModel(selectedDate: state.selectedDate, tasks: {state.selectedDate: newTasks});
  }

  void toggleTask(int index) {
    final currentTasks = List<Map<String, dynamic>>.from(state.currentTasks);
    currentTasks[index]['isDone'] = !currentTasks[index]['isDone'];
    state = TaskModel(selectedDate: state.selectedDate, tasks: {state.selectedDate: currentTasks});
  }

  void removeTask(int index) {
    final currentTasks = List<Map<String, dynamic>>.from(state.currentTasks);
    currentTasks.removeAt(index);
    state = TaskModel(selectedDate: state.selectedDate, tasks: {state.selectedDate: currentTasks});
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskModel>((ref) {
  return TaskNotifier();
});