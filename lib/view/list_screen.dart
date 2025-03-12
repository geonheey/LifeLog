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
import 'component/day_content.dart'; // DayContent를 import

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskModel = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.watch(taskNotifierProvider.notifier);
    final dayInt = taskModel.currentDays.length;
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
              itemCount: taskModel.currentDays.length +
                  taskModel.currentTasks.length +
                  taskModel.currentDiaries.length,
              itemBuilder: (context, index) {
                if (index < taskModel.currentDays.length) {
                  // DayContent가 가장 먼저 렌더링
                  final dayIndex = index;
                  final dayItem = taskModel.currentDays[dayIndex];
                  return DayContent(
                    day: dayItem['day'] as String,
                    onRemove: () => taskNotifier.removeDay(dayIndex),
                    onEdit: (updatedDay) async {
                      try {
                        await taskNotifier.updateDays(dayIndex, updatedDay);
                      } catch (e) {
                        print('Error updating day: $e');
                      }
                    },
                    index: dayIndex,
                  );
                } else if (index <
                    taskModel.currentDays.length +
                        taskModel.currentTasks.length) {
                  // 할 일 (Task) 처리
                  final taskIndex = index - taskModel.currentDays.length;
                  return ListContent(
                    task: taskModel.currentTasks[taskIndex]['task'],
                    isDone: taskModel.currentTasks[taskIndex]['isDone'],
                    onToggle: () => taskNotifier.toggleTask(taskIndex),
                    onRemove: () => taskNotifier.removeTask(taskIndex),
                  );
                } else {
                  // 일기 (Diary) 처리
                  final diaryIndex = index -
                      taskModel.currentDays.length -
                      taskModel.currentTasks.length;
                  final diaryItem = taskModel.currentDiaries[diaryIndex];
                  return DiaryContent(
                    diary: diaryItem['diary'] as String,
                    onRemove: () => taskNotifier.removeDiary(diaryIndex),
                    onEdit: () {
                      // 수정 버튼 추가
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryEditScreen(
                            initialDiary: diaryItem['diary'] as String,
                            onSave: (updatedDiary) async {
                              try {
                                await taskNotifier.updateDiary(
                                    diaryIndex, updatedDiary);
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEditScreen(
                    initialDiary: null,
                    onSave: (newDiary) async {
                      try {
                        await ref
                            .read(taskNotifierProvider.notifier)
                            .addDiary(newDiary);
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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddTaskDialog(
                    onTaskAdded: (task) async {
                      await taskNotifier.addTask(task);
                    },
                  );
                },
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.calendar_today_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddTaskDialog(
                    isTaskInitial: false,
                    onDayAdded: (day) async {
                      await taskNotifier.addDay(day);
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
