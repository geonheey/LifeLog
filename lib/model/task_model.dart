class TaskModel {
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> tasks;
  final Map<DateTime, List<Map<String, dynamic>>> diaries;
  final Map<DateTime, List<Map<String, dynamic>>> days;

  TaskModel({
    required this.selectedDate,
    required this.tasks,
    required this.diaries,
    required this.days,
  });

  // factory TaskModel.initial() {
  //   return TaskModel(
  //     selectedDate: DateTime.now(),
  //     tasks: {},
  //     diaries: {},
  //     days: {},
  //   );
  // }

  TaskModel copyWith({
    DateTime? selectedDate,
    Map<DateTime, List<Map<String, dynamic>>>? tasks,
    Map<DateTime, List<Map<String, dynamic>>>? diaries,
    Map<DateTime, List<Map<String, dynamic>>>? days,
  }) {
    return TaskModel(
      selectedDate: selectedDate ?? this.selectedDate,
      tasks: tasks ?? this.tasks,
      diaries: diaries ?? this.diaries,
      days: days ?? this.days,
    );
  }
  List<Map<String, dynamic>> get currentDiaries {
    return diaries[selectedDate] ?? [];
  }

  List<Map<String, dynamic>> get currentTasks {
    return tasks[selectedDate] ?? [];
  }

  List<Map<String, dynamic>> get currentDays {
    return days[selectedDate] ?? [];
  }
}
