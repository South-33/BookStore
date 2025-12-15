import 'package:flutter/material.dart';

class StudentApp extends StatelessWidget {
  Widget home;
  StudentApp({required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
    );
  }
}