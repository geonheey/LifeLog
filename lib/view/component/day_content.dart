import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_text_style.dart';
import '../../theme/todo_theme_color.dart';
import '../diary_detail_screen.dart'; // 사용하지 않는 경우 제거 가능
import 'add_task_dialog.dart';

class DayContent extends StatelessWidget {
  final String day;
  final VoidCallback onRemove;
  final Function(String) onEdit;
  final int index;

  const DayContent({
    super.key,
    required this.day,
    required this.onRemove,
    required this.onEdit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: GestureDetector(
            onTap: () => _showEditDialog(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 3, 24, 0),
                  child: Icon(
                    Icons.star_border_outlined,
                    color : TodoThemeColor.red,
                    size: 24,
                    // color: TodoThemeColor.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    day,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TodoThemeTextStyle.blackMedium15,
                  ),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.expand_circle_down_outlined),
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
          initialText: day,
          isTaskInitial: false,
          onDayAdded: (updatedDay) async {
            await onEdit(updatedDay);
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
