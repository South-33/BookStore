import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import '../student_module/logged_user.dart';
import 'customer_model.dart';

class CustomerService {
  final _base = Platform.isAndroid 
      ? "http://10.0.2.2:8000/api" 
      : "http://127.0.0.1:8000/api";

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

  Future<CustomerModel> getData() async {
    LoggedUser user = await login("test@example.com", "123456");

    http.Response res = await http.get(
      Uri.parse("$_base/customers?page=1"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${user.token}",
      },
    );
    try {
      if (res.statusCode == 200) {
        return compute(customerModelFromJson, res.body);
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> store(Customer item) async {
    LoggedUser user = await login("test@example.com", "123456");

    http.Response res = await http.post(
      Uri.parse("$_base/customers"),
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
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> update(Customer item) async {
    LoggedUser user = await login("test@example.com", "123456");

    http.Response res = await http.put(
      Uri.parse("$_base/customers/${item.id}"),
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
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<bool> destroy(int id) async {
    LoggedUser user = await login("test@example.com", "123456");

    http.Response res = await http.delete(
      Uri.parse("$_base/customers/$id"),
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
      } else {
        throw Exception(
          "Error Status Code: ${res.statusCode} \n Error: ${res.body}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }
}
