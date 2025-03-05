import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/theme/todo_theme_color.dart';

import 'app_bar_text.dart';

class ToDoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  ToDoAppBar({Key? key})
    : preferredSize = const Size.fromHeight(60),
      super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: TodoThemeColor.background,
      elevation: 4,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.date_range, color: TodoThemeColor.black),
          SizedBox(width: 16),
          AppBarText(),
        ],
      ),
    );
  }
}
