import 'package:flutter/material.dart';

import '../../theme/todo_theme_text_style.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String) onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String newTask = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('할 일 추가', style:TodoThemeTextStyle.blackMedium17 ,),
      content: TextField(
        onChanged: (value) {
          setState(() {
            newTask = value;
          });
        },
        decoration: const InputDecoration(hintText: '할 일을 입력하세요', hintStyle: TodoThemeTextStyle.grayMedium14),
      ),
      actions: [
        TextButton(
          onPressed: () {
              widget.onTaskAdded(newTask);
              Navigator.of(context).pop();
          },
          child: const Text('추가', style : TodoThemeTextStyle.blackMedium17),
        ),
      ],
    );
  }
}
