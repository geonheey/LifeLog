import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

class AddTaskDialog extends StatefulWidget {
  final Future<void> Function(String task)? onTaskAdded;
  final Future<void> Function(String day)? onDayAdded;
  final String? initialText;
  final bool? isTaskInitial;
  final bool isTask;

  const AddTaskDialog({
    super.key,
    this.onTaskAdded,
    this.onDayAdded,
    this.initialText,
    this.isTaskInitial, required this.isTask,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late TextEditingController _textController;
  late bool isTask;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    isTask = widget.isTask;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialText != null;
    return AlertDialog(
      title: Text(isEditing ? (isTask ? '할 일 수정' : '일정 수정') : (isTask ? '할 일 추가' : '일정 추가')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: isTask ? '할 일' : '일정',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final inputText = _textController.text.trim();
            if (inputText.isNotEmpty) {
              if (isTask && widget.onTaskAdded != null) {
                widget.onTaskAdded!(inputText);
              } else if (!isTask && widget.onDayAdded != null) {
                widget.onDayAdded!(inputText);
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? (isTask ? '수정' : '수정') : (isTask ? '추가' : '추가'),
              style: TextStyle(color: TodoThemeColor.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

          },
          child: const Text('취소', style: TextStyle(color: TodoThemeColor.black)),
        ),
      ],
    );
  }
}
