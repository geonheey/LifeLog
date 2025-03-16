import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';
import 'package:to_do_list/view/component/to_do_app_bar.dart';
import '../model/task_model.dart';
import '../view_model/task_notifier.dart';
import 'component/add_task_dialog.dart';
import 'component/diary_content.dart';
import 'component/to_do_calendar2.dart';
import 'diary_edit_screen.dart';
import 'component/list_content.dart';
import 'component/to_do_calendar.dart';
import 'component/day_content.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  List<DateTime> _getEvents(TaskModel taskModel) {
    final List<DateTime> events = [];
    taskModel.days.forEach((date, dayList) {
      if (dayList.isNotEmpty) events.add(date);
    });
    taskModel.tasks.forEach((date, taskList) {
      if (taskList.isNotEmpty) events.add(date);
    });
    taskModel.diaries.forEach((date, diaryList) {
      if (diaryList.isNotEmpty) events.add(date);
    });
    return events.toSet().toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskModel = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.watch(taskNotifierProvider.notifier);

    final currentDays = taskModel.days[taskModel.selectedDate] ?? [];
    final currentTasks = taskModel.tasks[taskModel.selectedDate] ?? [];
    final currentDiaries = taskModel.diaries[taskModel.selectedDate] ?? [];

    return Scaffold(
      appBar: ToDoAppBar(),
      body: Column(
        children: [
          ToDoCalendar(
            onDateChanged: (selectedDate) {
              taskNotifier.setSelectedDate(selectedDate);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentDays.length + currentTasks.length + currentDiaries.length,
              itemBuilder: (context, index) {
                if (index < currentDays.length) {
                  final dayIndex = index;
                  final dayItem = currentDays[dayIndex];
                  return DayContent(
                    day: (dayItem['day'] ?? '') as String,
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
                } else if (index < currentDays.length + currentTasks.length) {
                  final taskIndex = index - currentDays.length;
                  return ListContent(
                    task: currentTasks[taskIndex]['task'] as String? ?? '',
                    isDone: currentTasks[taskIndex]['isDone'] as bool? ?? false,
                    onToggle: () => taskNotifier.toggleTask(taskIndex),
                    onRemove: () => taskNotifier.removeTask(taskIndex),
                    onEdit: (updatedTask, isDone) async {
                      try {
                        await taskNotifier.updateTasks(taskIndex, updatedTask, isDone);
                      } catch (e) {
                        print('Error updating task: $e');
                      }
                    },
                  );

                } else {
                  final diaryIndex = index - currentDays.length - currentTasks.length;
                  final diaryItem = currentDiaries[diaryIndex];
                  return DiaryContent(
                    diary: diaryItem['diary'] as String,
                    onRemove: () => taskNotifier.removeDiary(diaryIndex),
                    onEdit: () {
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
            child: const Icon(CupertinoIcons.pen),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEditScreen(
                    initialDiary: null,
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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddTaskDialog(
                    isTask: true,
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
                    isTask: false,
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