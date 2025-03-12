import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';
import 'package:to_do_list/view/component/to_do_app_bar.dart';

import '../view_model/task_notifier.dart';
import 'component/add_task_dialog.dart';
import 'component/diary_content.dart';
import 'component/diary_edit_screen.dart';
import 'component/list_content.dart';
import 'component/to_do_calendar.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskModel = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.watch(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: ToDoAppBar(),
      body: Column(
        children: [
          ToDoCalendar(
            onDateChanged: (date) {
              taskNotifier.setSelectedDate(date);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskModel.currentTasks.length +
                  taskModel.currentDiaries.length,
              itemBuilder: (context, index) {
                if (index < taskModel.currentTasks.length) {
                  return ListContent(
                    task: taskModel.currentTasks[index]['task'],
                    isDone: taskModel.currentTasks[index]['isDone'],
                    onToggle: () => taskNotifier.toggleTask(index),
                    onRemove: () => taskNotifier.removeTask(index),
                  );
                } else {
                  final diaryIndex = index - taskModel.currentTasks.length;
                  final diaryItem = taskModel.currentDiaries[diaryIndex];
                  return DiaryContent(
                    diary: diaryItem['diary'] as String,
                    onRemove: () => taskNotifier.removeDiary(diaryIndex),
                    onEdit: () { // 수정 버튼 추가
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryEditScreen(
                            initialDiary: diaryItem['diary'] as String,
                            onSave: (updatedDiary) async {
                              try {
                                await taskNotifier.updateDiary(diaryIndex, updatedDiary);
                              } catch (e) {
                                print('Error updating diary: $e');
                              }
                            },
                          ),
                        ),
                      );
                    },
                    index: diaryIndex,
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: TodoThemeColor.primary,
        foregroundColor: TodoThemeColor.white,
        child: const Icon(Icons.add),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: "일기 쓰기",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEditScreen(
                    initialDiary: "", // 새 일기이므로 빈 문자열
                    onSave: (newDiary) async {
                      try {
                        await ref.read(taskNotifierProvider.notifier).addDiary(newDiary);
                      } catch (e) {
                        print('Error adding diary: $e');
                      }
                    },
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.check),
            label: "할 일 추가",
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddTaskDialog(
                    onTaskAdded: (task) async {
                      await taskNotifier.addTask(task);
                    },
                    onDiaryAdded: (diary) async {
                      await taskNotifier.addDiary(diary);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}