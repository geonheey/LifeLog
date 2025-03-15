import 'package:flutter/material.dart';

import '../theme/todo_theme_text_style.dart';

class DiaryEditScreen extends StatefulWidget {
  final String? initialDiary;
  final ValueChanged<String> onSave;

  const DiaryEditScreen({super.key, this.initialDiary, required this.onSave});

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDiary);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialDiary == null ? "새 일기 작성" : "일기 수정", style: TodoThemeTextStyle.blackMedium20,),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onSave(_controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "여기에 일기를 작성하세요...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
