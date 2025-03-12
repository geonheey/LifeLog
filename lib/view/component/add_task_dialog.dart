import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

class AddTaskDialog extends StatefulWidget {
  final Future<void> Function(String task)? onTaskAdded;
  final Future<void> Function(String diary)? onDiaryAdded;
  final String? initialText;
  final bool? isTaskInitial;

  const AddTaskDialog({
    super.key,
    this.onTaskAdded,
    this.onDiaryAdded,
    this.initialText,
    this.isTaskInitial,
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
    isTask = widget.isTaskInitial ?? true;
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
      title: Text(isEditing ? '할 일 수정' : '할 일 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: '할 일',
            ),
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final inputText = _textController.text.trim();
            if (inputText.isNotEmpty && isTask && widget.onTaskAdded != null) {

                widget.onTaskAdded!(inputText);

              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? '수정' : '추가', style: TextStyle( color:  TodoThemeColor.black,)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소',style: TextStyle( color:  TodoThemeColor.black,)),
        ),
      ],
    );
  }
}