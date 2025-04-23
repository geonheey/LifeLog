import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/theme/todo_theme_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBarText extends ConsumerWidget {
  const AppBarText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '나의 ', style: TodoThemeTextStyle.primaryBold23),
              WidgetSpan(child: const SizedBox(width: 8)),
              TextSpan(text: 'ToDo', style: TodoThemeTextStyle.darkBold23),
            ],
          ),
        ),
      ],
    );
  }
}