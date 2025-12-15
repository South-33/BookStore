import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book_logic.dart';
import 'book_splash_screen.dart';

Widget bookProvider() {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => BookLogic())],
    child: BookSplashScreen(),
  );
}
