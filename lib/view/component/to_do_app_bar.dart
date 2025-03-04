import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';

class ToDoAppBar extends StatelessWidget {
  const ToDoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        onDateChanged: (value) => print(value),
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
      ),
    );
  }
}
