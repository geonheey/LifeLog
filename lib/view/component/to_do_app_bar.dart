import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';

class ToDoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(DateTime) onDateChanged;

  @override
  final Size preferredSize;

  ToDoAppBar({Key? key, required this.onDateChanged})
      : preferredSize = const Size.fromHeight(220),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarAppBar(
      onDateChanged: (date) => onDateChanged(date),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 4)),
      fullCalendar: false,
      backButton: false,
      events: [],
    );
  }
}
