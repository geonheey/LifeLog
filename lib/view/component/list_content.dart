import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

import '../../theme/todo_theme_text_style.dart';

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
            icon: Icon(Icons.dangerous_outlined),
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
  void _showBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text("정말 다 했어? 오늘 열심히 살았어?"),
          actions: [
            CupertinoActionSheetAction(
              child: Text('삭제',style: TodoThemeTextStyle.redMedium17,),
              onPressed: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('취소', style: TodoThemeTextStyle.blackMedium17,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

