import 'package:flutter/material.dart';

class DiaryContent extends StatelessWidget {
  final String diary;
  final VoidCallback onRemove;

  const DiaryContent({
    super.key,
    required this.diary,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(diary),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onRemove,
      ),
    );
  }
}
