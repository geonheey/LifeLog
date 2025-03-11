import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/todo_theme_color.dart';
import '../../view_model/task_notifier.dart';
import '../diary_detail_screen.dart';
import 'diary_edit_screen.dart';

class DiaryContent extends ConsumerWidget {
  final String diary;
  final int index;
  final VoidCallback onRemove;

  const DiaryContent({
    super.key,
    required this.diary,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  padding: const EdgeInsets.fromLTRB(12,3,12,0),
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryEditScreen(
                        initialDiary: diary,
                        onSave: (updatedDiary) async {
                          try {
                            await ref.read(taskNotifierProvider.notifier).updateDiary(index, updatedDiary);
                          } catch (e) {
                            print('Error updating diary: $e');
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              // 🗑️ 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(taskNotifierProvider.notifier).removeDiary(index),
              ),
            ],
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
