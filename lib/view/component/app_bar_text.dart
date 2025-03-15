import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Material 아이콘 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/theme/todo_theme_text_style.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 열기 패키지 추가

class AppBarText extends ConsumerWidget {
  const AppBarText({super.key});

  Future<void> _launchLink() async {
    final Uri url = Uri.parse('https://www.notion.so/11e6fcb1a9654a6c98a797be18b6fb71');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        print('Successfully launched $url');
      } else {
        print('Cannot launch $url');
      }
    } catch (e) {
      print('Error launching $url: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '앙거니의', style: TodoThemeTextStyle.primaryBold23),
              WidgetSpan(child: const SizedBox(width: 8)),
              TextSpan(text: 'ToDo', style: TodoThemeTextStyle.darkBold23),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.link, color: Colors.blue),
          onPressed: _launchLink,
          tooltip: 'Visit website',
        ),
      ],
    );
  }
}