import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/todo_theme_text_style.dart';

class DiaryDetailScreen extends StatelessWidget {
  final String diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("일기 상세 보기",style: TodoThemeTextStyle.blackMedium20,)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            diary,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}