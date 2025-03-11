import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/theme/todo_theme_text_style.dart';

class AppBarText extends ConsumerWidget {
  const AppBarText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '앙거니의', style: TodoThemeTextStyle.primaryBold23),
          WidgetSpan(child: SizedBox(width: 8)),
          TextSpan(text: 'ToDo', style: TodoThemeTextStyle.darkBold23),
        ],
      ),
    );
  }
}
