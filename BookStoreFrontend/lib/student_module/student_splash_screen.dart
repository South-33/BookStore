import 'package:flutter/material.dart';
import 'student_screen.dart';
import 'logged_user.dart';
import 'login_screen.dart';
import 'student_app.dart';
import 'student_logic.dart';
import 'package:provider/provider.dart';

class StudentSplashScreen extends StatefulWidget {
  const StudentSplashScreen({super.key});

  @override
  State<StudentSplashScreen> createState() => _StudentSplashScreenState();
}

class _StudentSplashScreenState extends State<StudentSplashScreen> {
  Future _readCache() async {
    if (mounted) {
      await Future.delayed(Duration(seconds: 1), () {});
      return Future.wait([context.read<StudentLogic>().readCacheUser()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: _readCache(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Cache Error: ${snapshot.error}");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                final LoggedUser user = context.watch<StudentLogic>().user;
                if (user.token != "token") {
                  return StudentApp(home: StudentScreen());
                } else {
                  return StudentApp(home: LoginScreen());
                }
              } else {
                return _buildLoading();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.person, size: 100), CircularProgressIndicator()],
      ),
    );
  }
}
