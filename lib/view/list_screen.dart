import 'package:flutter/material.dart';
import 'component/list_content.dart';

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Map<String, dynamic>> tasks = List.generate(20, (index) => {
    'task': '',
    'isDone': false,
  });


  void _addTask(String task) {
    setState(() {
      tasks.add({'task': task, 'isDone': false});
    });
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['isDone'] = !tasks[index]['isDone'];
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _showAddTaskDialog() {
    String newTask = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('할 일 추가'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: InputDecoration(hintText: '할 일을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  _addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 목록'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListContent(
            task: tasks[index]['task'],
            isDone: tasks[index]['isDone'],
            onToggle: () => _toggleTask(index),
            onRemove: () => _removeTask(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
