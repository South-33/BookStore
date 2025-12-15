import 'package:flutter/material.dart';
import 'customer_screen.dart';

class CustomerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustomerScreen(),
    );
  }
}
