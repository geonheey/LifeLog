import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';

class ToDoCalendar2 extends StatefulWidget {
  final List<DateTime> events;
  final Function(DateTime) onDateChanged;

  const ToDoCalendar2({
    Key? key,
    required this.events,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  _ToDoCalendar2State createState() => _ToDoCalendar2State();
}

class _ToDoCalendar2State extends State<ToDoCalendar2> {
  final _calendarControllerCustom = AdvancedCalendarController(DateTime.now());



  @override
  void initState() {
    super.initState();
    _calendarControllerCustom.addListener(() {
      widget.onDateChanged(_calendarControllerCustom.value);
    });
  }

  @override
  void dispose() {
    _calendarControllerCustom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedCalendar(
      controller: _calendarControllerCustom,
      events: widget.events,
      weekLineHeight: 48.0,
      startWeekDay: 0,
      innerDot: true,
      preloadMonthViewAmount: 13,
      preloadWeekViewAmount: 21,
      weeksInMonthViewAmount: 6,
      calendarTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.3125,
        letterSpacing: 0,
      ),
      headerStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}