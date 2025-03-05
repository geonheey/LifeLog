import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/view/component/to_do_app_bar.dart';
import '../view_model/task_notifier.dart';
import 'component/list_content.dart';
import 'component/add_task_dialog.dart';

class TodoApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final taskModel = ref.watch(taskNotifierProvider);
    final taskNotifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: ToDoAppBar(
        onDateChanged: (date) {
          taskNotifier.setSelectedDate(date);
        },
      ),
      body: ListView.builder(
        itemCount: taskModel.currentTasks.length,
        itemBuilder: (context, index) {
          return ListContent(
            task: taskModel.currentTasks[index]['task'],
            isDone: taskModel.currentTasks[index]['isDone'],
            onToggle: () => taskNotifier.toggleTask(index),
            onRemove: () => taskNotifier.removeTask(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddTaskDialog(
                onTaskAdded: (task) {
                  taskNotifier.addTask(task);
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
