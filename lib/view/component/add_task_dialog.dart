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
  late TextEditingController _textController; // Use a controller for stability
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
      title: Text(isEditing
          ? (isTask ? '할 일 수정' : '일기 수정')
          : (isTask ? '새 할 일 추가' : '새 일기 추가')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: isTask ? '할 일' : '일기 내용',
            ),
          ),
          if (!isEditing) ...[
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTask ? TodoThemeColor.primary : null,
                  ),
                  child: const Text('할 일', style: TextStyle( color:  TodoThemeColor.white,)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isTask = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isTask ? TodoThemeColor.primary : null,
                  ),
                  child: const Text('일기', style: TextStyle( color:  TodoThemeColor.white,)),                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final inputText = _textController.text.trim();
            if (inputText.isNotEmpty) {
              if (isTask && widget.onTaskAdded != null) {
                widget.onTaskAdded!(inputText);
              } else if (!isTask && widget.onDiaryAdded != null) {
                widget.onDiaryAdded!(inputText);
              }
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