import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../view_model/task_notifier.dart';

class ToDoCalendar extends ConsumerWidget {
  final Function(DateTime) onDateChanged;

  const ToDoCalendar({Key? key, required this.onDateChanged}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) {
        return isSameDay(day, ref.watch(taskNotifierProvider).selectedDate);
      },
      onDaySelected: (selectedDay, focusedDay) {
        onDateChanged(selectedDay);
      },
    );
  }
}
