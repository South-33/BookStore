import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'registered_user.dart';
import 'logged_user.dart';

import 'book_logic.dart';
import 'book_model.dart';

class BookService {
  // 10.0.2.2 for Android emulator, 127.0.0.1 for Windows/iOS
  final _base = Platform.isAndroid 
      ? "http://10.0.2.2:8000/api" 
      : "http://127.0.0.1:8000/api";

  Future<RegisteredUser> register(
    String name,
    String email,
    String password,
  ) async {
    Map<String, dynamic> userMap = {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": password,
    };

    http.Response res = await http.post(
      Uri.parse("$_base/register"),
      body: jsonEncode(userMap),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint(res.body);
        return compute(registeredUserFromJson, res.body);
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<LoggedUser> login(String email, String password) async {
    http.Response res = await http.post(
      Uri.parse("$_base/login"),
      body: jsonEncode({"email": email, "password": password}),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint(res.body);
        return compute(loggedUserFromJson, res.body);
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<BookModel> searchData(BuildContext context, String keyword) async {
    LoggedUser user = context.read<BookLogic>().user;

    http.Response res = await http.get(
      Uri.parse("$_base/books?search=$keyword"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 200) {
        return compute(bookModelFromJson, res.body);
      } else if (res.statusCode == 401) {
        await logout(context);
        throw Exception(
          "Error response code: ${res.statusCode} \n ${res.body}",
        );
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<BookModel> getData(BuildContext context, LoggedUser user) async {
    http.Response res = await http.get(
      Uri.parse("$_base/books?page=1"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 200) {
        return compute(bookModelFromJson, res.body);
      } else if (res.statusCode == 401) {
        await logout(context);
        throw Exception(
          "Error response code: ${res.statusCode} \n ${res.body}",
        );
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> store(BuildContext context, Book item) async {
    LoggedUser user = context.read<BookLogic>().user;
    
    http.Response res = await http.post(
      Uri.parse("$_base/books"),
      body: jsonEncode(item.toJson()),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 201) {
        debugPrint(res.body);
        return true;
      } else if (res.statusCode == 401) {
        await logout(context);
        throw Exception(
          "Error response code: ${res.statusCode} \n ${res.body}",
        );
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> update(BuildContext context, Book item) async {
    LoggedUser user = context.read<BookLogic>().user;
    
    http.Response res = await http.put(
      Uri.parse("$_base/books/${item.id}"),
      body: jsonEncode(item.toJson()),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 200) {
        debugPrint(res.body);
        return true;
      } else if (res.statusCode == 401) {
        await logout(context);
        throw Exception(
          "Error response code: ${res.statusCode} \n ${res.body}",
        );
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> destroy(BuildContext context, int id) async {
    LoggedUser user = context.read<BookLogic>().user;
    
    http.Response res = await http.delete(
      Uri.parse("$_base/books/$id"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 200) {
        debugPrint(res.body);
        return true;
      } else if (res.statusCode == 401) {
        await logout(context);
        throw Exception(
          "Error response code: ${res.statusCode} \n ${res.body}",
        );
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future logout(BuildContext context) async {
    final url = "$_base/logout";
    LoggedUser user = context.read<BookLogic>().user;
    debugPrint("logout user's token: ${user.token}");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${user.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        debugPrint("logout: ${response.body}");
      } else if (response.statusCode == 401) {
        throw Exception("Error response code: ${response.statusCode}");
      } else {
        throw Exception("Error response code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    } finally {
      context.read<BookLogic>().clearCacheUser();
      Navigator.of(
        context,
      ).pushReplacement(CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
  }
}
