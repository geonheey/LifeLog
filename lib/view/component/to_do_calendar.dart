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
    _focusedDay = tz.TZDateTime.now(detroit);
  }

  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskNotifierProvider).tasks;
    final diaries = ref.watch(taskNotifierProvider).diaries;
    final days = ref.watch(taskNotifierProvider).days;


    final selectedDate = ref.watch(taskNotifierProvider).selectedDate;
    return TableCalendar(
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(day, selectedDate);
      },
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
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
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: TodoThemeColor.primaryLight2,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: TodoThemeColor.primary,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: TodoThemeColor.primaryLight2),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          // 태스크 체크
          final hasTasks = tasks.entries
              .where(
                (entry) => isSameDay(entry.key, date) && entry.value.isNotEmpty,
          )
              .isNotEmpty;

          // 일기 체크
          final hasDiaries = diaries.entries
              .where(
                (entry) => isSameDay(entry.key, date) && entry.value.isNotEmpty,
          )
              .isNotEmpty;
          // 일정 체크
          final hasDays = days.entries
              .where(
                (entry) => isSameDay(entry.key, date) && entry.value.isNotEmpty,
          )
              .isNotEmpty;

          if (hasTasks || hasDiaries || hasDays) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasDays)
                  Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.only(right: 2.0),
                    decoration: const BoxDecoration(
                      color: TodoThemeColor.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasTasks)
                  Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.only(right: 2.0),
                    decoration: const BoxDecoration(
                      color: TodoThemeColor.gray,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasDiaries)
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: TodoThemeColor.gray2,
                      shape: BoxShape.circle,
                    ),
                  ),

              ],
            );
          }

          return null;
        },
      ),
    );
  }
}