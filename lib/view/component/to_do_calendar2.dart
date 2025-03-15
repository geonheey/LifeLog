// import 'package:flutter/material.dart';
// import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
// import 'package:to_do_list/theme/todo_theme_color.dart';
//
// class ToDoCalendar2 extends StatefulWidget {
//   final List<DateTime> events;
//   final Function(DateTime) onDateChanged;
//
//   const ToDoCalendar2({
//     Key? key,
//     required this.events,
//     required this.onDateChanged,
//   }) : super(key: key);
//
//   @override
//   _ToDoCalendar2State createState() => _ToDoCalendar2State();
// }
//
// class _ToDoCalendar2State extends State<ToDoCalendar2> {
//   final _calendarControllerCustom = AdvancedCalendarController(DateTime.now());
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _calendarControllerCustom.addListener(() {
//       widget.onDateChanged(_calendarControllerCustom.value);
//     });
//   }
//
//   @override
//   void dispose() {
//     _calendarControllerCustom.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Theme(
//       data: theme.copyWith(
//         textTheme: theme.textTheme.copyWith(
//           titleMedium: theme.textTheme.titleMedium!.copyWith(
//             fontSize: 16,
//             color: theme.colorScheme.secondary,
//           ),
//           bodyLarge: theme.textTheme.bodyLarge!.copyWith(
//             fontSize: 14,
//             color: Colors.black54,
//           ),
//           bodyMedium: theme.textTheme.bodyMedium!.copyWith(
//             fontSize: 12,
//             color: Colors.black87,
//           ),
//         ),
//         primaryColor: TodoThemeColor.primary,
//         highlightColor: TodoThemeColor.primaryLight2,
//         disabledColor: TodoThemeColor.primaryLight2,
//       ),
//       child: AdvancedCalendar(
//         controller: _calendarControllerCustom,
//         events: widget.events,
//         weekLineHeight: 48.0,
//         startWeekDay: 1,
//         innerDot: true,
//         keepLineSize: true,
//         calendarTextStyle: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w400,
//           height: 1.3125,
//           letterSpacing: 0,
//         ),
//       ),
//     );
//   }
// }
