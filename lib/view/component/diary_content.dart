import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme/todo_theme_text_style.dart';
import '../../theme/todo_theme_color.dart';
import '../diary_detail_screen.dart';

class DiaryContent extends StatelessWidget {
  final String diary;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final int index;

  const DiaryContent({
    super.key,
    required this.diary,
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailScreen(diary: diary),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 3, 24, 0),
                  child: Icon(
                    Icons.library_books,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Text(
                    diary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_circle),
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
          actions: [
            CupertinoActionSheetAction(
              child: Text('수정', style: TodoThemeTextStyle.blackMedium17,),
              onPressed: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
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
