import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list/view/list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseDatabase.instance.setPersistenceEnabled(true);
  tz.initializeTimeZones();
  await dotenv.load(fileName: '.env');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('com.example.to_do_list/task_channel');

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData.light().copyWith(
      //   textTheme: ThemeData.light().textTheme.apply(
      //     fontFamily: 'Pretendard',
      //   ),
      // ),
      // darkTheme: ThemeData.dark(),
      title: 'Todo App',
      home: const ListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}