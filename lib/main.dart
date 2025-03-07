import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/view/list_screen.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('com.example.to_do_list/task_channel');

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: ListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
