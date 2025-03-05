import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String) onTaskAdded;

  const AddTaskDialog({Key? key, required this.onTaskAdded}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String newTask = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('할 일 추가'),
      content: TextField(
        onChanged: (value) {
          setState(() {
            newTask = value;
          });
        },
        decoration: const InputDecoration(hintText: '할 일을 입력하세요'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (newTask.isNotEmpty) {
              widget.onTaskAdded(newTask);
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}
