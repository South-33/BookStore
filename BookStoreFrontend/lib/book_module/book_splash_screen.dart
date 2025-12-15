import 'package:flutter/material.dart';
import 'store_screen.dart';
import 'logged_user.dart';
import 'login_screen.dart';
import 'book_app.dart';
import 'book_logic.dart';
import 'package:provider/provider.dart';

class BookSplashScreen extends StatefulWidget {
  const BookSplashScreen({super.key});

  @override
  State<BookSplashScreen> createState() => _BookSplashScreenState();
}

class _BookSplashScreenState extends State<BookSplashScreen> {
  Future _readCache() async {
    if (mounted) {
      await Future.delayed(Duration(seconds: 1), () {});
      return Future.wait([context.read<BookLogic>().readCacheUser()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FutureBuilder(
            future: _readCache(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                final LoggedUser user = context.watch<BookLogic>().user;
                if (user.token != "token") {
                  return BookApp(home: StoreScreen());
                } else {
                  return BookApp(home: LoginScreen());
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFe94560),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFe94560).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.menu_book, size: 50, color: Colors.white),
        ),
        SizedBox(height: 30),
        Text(
          "BookStore",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a2e),
          ),
        ),
        SizedBox(height: 30),
        CircularProgressIndicator(color: Color(0xFFe94560)),
      ],
    );
  }
}
