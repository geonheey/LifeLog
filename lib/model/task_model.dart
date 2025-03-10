class TaskModel {
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> tasks;
  final Map<DateTime, List<Map<String, dynamic>>> diaries;

  TaskModel({
    required this.selectedDate,
    required this.tasks,
    required this.diaries,
  });

  factory TaskModel.initial() {
    return TaskModel(
      selectedDate: DateTime.now(),
      tasks: {},
      diaries: {},
    );
  }

  TaskModel copyWith({
    DateTime? selectedDate,
    Map<DateTime, List<Map<String, dynamic>>>? tasks,
    Map<DateTime, List<Map<String, dynamic>>>? diaries,
  }) {
    return TaskModel(
      selectedDate: selectedDate ?? this.selectedDate,
      tasks: tasks ?? this.tasks,
      diaries: diaries ?? this.diaries,
    );
  }

  List<Map<String, dynamic>> get currentDiaries {
    return diaries[selectedDate] ?? [];
  }

  List<Map<String, dynamic>> get currentTasks {
    return tasks[selectedDate] ?? [];
  }
}
