import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'student_logic.dart';
import 'student_splash_screen.dart';

Widget studentProvider() {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => StudentLogic())],
    child: StudentSplashScreen(),
  );
}
