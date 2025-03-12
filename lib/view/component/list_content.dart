import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

class ListContent extends StatelessWidget {
  final String task;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const ListContent({
    super.key,
    required this.task,
    required this.isDone,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            task,
            style: TextStyle(
              fontSize: 15,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          leading: Checkbox(
            value: isDone,
            activeColor: TodoThemeColor.primary,
            onChanged: (value) {
              onToggle();
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onRemove,
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
}
