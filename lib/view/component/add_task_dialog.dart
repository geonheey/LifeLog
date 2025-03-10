import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Future<void> Function(String task) onTaskAdded;
  final Future<void> Function(String diary) onDiaryAdded;

  const AddTaskDialog({
    super.key,
    required this.onTaskAdded,
    required this.onDiaryAdded,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String inputText = '';
  bool isTask = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isTask ? '새 할 일 추가' : '새 일기 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                inputText = value;
              });
            },
            decoration: InputDecoration(
              labelText: isTask ? '할 일' : '일기 내용',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTask = true;
                  });
                },
                child: const Text('할 일'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTask = false;
                  });
                },
                child: const Text('일기'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (inputText.isNotEmpty) {
              if (isTask) {
                widget.onTaskAdded(inputText);
              } else {
                widget.onDiaryAdded(inputText);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
      ],
    );
  }
}
