import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';
import '../../view_model/task_notifier.dart';

class ToDoCalendar extends ConsumerStatefulWidget {
  final Function(DateTime) onDateChanged;

  const ToDoCalendar({Key? key, required this.onDateChanged}) : super(key: key);

  @override
  _ToDoCalendarState createState() => _ToDoCalendarState();
}

class _ToDoCalendarState extends ConsumerState<ToDoCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskNotifierProvider).tasks;
    final selectedDate = ref.watch(taskNotifierProvider).selectedDate;

    return TableCalendar(
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2035, 3, 5),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(day, selectedDate);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        // leftChevronVisible: false,
        // rightChevronVisible: false,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDateChanged(selectedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: TodoThemeColor.red1,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: TodoThemeColor.orange,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: TodoThemeColor.red),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final tasksForDate = tasks.entries
              .where((entry) => isSameDay(entry.key, date))
              .map((entry) => entry.value)
              .expand((taskList) => taskList)
              .toList();

          if (tasksForDate.isNotEmpty) {
            return Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: TodoThemeColor.gray1,
                shape: BoxShape.circle,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}
