class TaskModel {
  DateTime selectedDate;
  Map<DateTime, List<Map<String, dynamic>>> tasks;

  TaskModel({
    required this.selectedDate,
    required this.tasks,
  });

  List<Map<String, dynamic>> get currentTasks {
    return tasks[selectedDate] ?? [];
  }
}
