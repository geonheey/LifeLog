import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../view_model/task_notifier.dart';

class ToDoCalendar extends ConsumerStatefulWidget {
  final Function(DateTime) onDateChanged;

  const ToDoCalendar({super.key, required this.onDateChanged});

  @override
  _ToDoCalendarState createState() => _ToDoCalendarState();
}

class _ToDoCalendarState extends ConsumerState<ToDoCalendar> {
  late DateTime _focusedDay;
  var detroit = tz.getLocation('Asia/Seoul');


  @override
  void initState() {
    super.initState();
    _focusedDay =tz.TZDateTime.now(detroit);
  }
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.d(_focusedDay);

    final tasks = ref.watch(taskNotifierProvider).tasks;
    final selectedDate = ref.watch(taskNotifierProvider).selectedDate;
    return TableCalendar(
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(day, selectedDate);
      },
      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDateChanged(selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDateChanged(focusedDay);
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
          final tasksForDate =
              tasks.entries
                  .where(
                    (entry) =>
                        isSameDay(entry.key, date) && entry.value.isNotEmpty,
                  )
                  .toList();

          if (tasksForDate.isNotEmpty) {
            return Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: TodoThemeColor.gray,
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
