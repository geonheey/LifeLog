import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

import '../../theme/todo_theme_text_style.dart';
import 'add_task_dialog.dart';

class ListContent extends StatelessWidget {
  final String task;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final Future<void> Function(String, bool) onEdit;


  const ListContent({
    super.key,
    required this.task,
    required this.isDone,
    required this.onToggle,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 24, 0),
          visualDensity: VisualDensity(vertical: -3),
          leading: Checkbox(
            value: isDone,
            activeColor: TodoThemeColor.dark,
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) {
              onToggle();
            },
          ),
          title: GestureDetector(
            onTap: () => _showEditDialog(context),
            child: Text(
              task,
              style: TextStyle(
                color: TodoThemeTextStyle.blackMedium15.color,
                fontSize: TodoThemeTextStyle.blackMedium15.fontSize,
                fontWeight: TodoThemeTextStyle.blackMedium15.fontWeight,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(CupertinoIcons.delete),
            iconSize: 15,
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
        ),
        const Divider(
          color: TodoThemeColor.gray2,
          height: 1,
          thickness: 1,
          indent: 15,
          endIndent: 15,
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          isTask: true,
          initialText: task,
          isTaskInitial: false,
          onTaskAdded: (updatedTask) async {
            await onEdit(updatedTask, isDone);
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                '삭제',
                style: TodoThemeTextStyle.redMedium17,
              ),
              onPressed: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              '취소',
              style: TodoThemeTextStyle.blackMedium17,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
