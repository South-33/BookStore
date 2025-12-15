import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'google_books_model.dart';
import 'logged_user.dart';

class PurchasedBookService {
  static const String baseUrl = "http://127.0.0.1:8000/api";
  final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      String? value = await _storage.read(key: 'BookLogic');
      if (value != null) {
        LoggedUser user = loggedUserFromJson(value);
        return user.token;
      }
    } catch (e) {
      print('Error getting token: $e');
    }
    return null;
  }

  Future<List<dynamic>> getPurchasedBooks() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/purchased-books"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      print('Error loading purchased books: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  Future<bool> purchaseBooks(List<GoogleBook> books) async {
    final token = await _getToken();
    if (token == null) return false;

    final booksData = books.map((book) => {
      "google_book_id": book.id,
      "title": book.volumeInfo.title,
      "authors": book.volumeInfo.authors,
      "thumbnail": book.volumeInfo.thumbnail,
      "price": book.saleInfo?.listPrice?.amount ?? 0,
    }).toList();

    final response = await http.post(
      Uri.parse("$baseUrl/purchased-books"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"books": booksData}),
    );

    print('Purchase response: ${response.statusCode} - ${response.body}');
    return response.statusCode == 201;
  }

  Future<bool> updatePurchasedBook(int bookId, {int? rating, String? notes, String? status}) async {
    final token = await _getToken();
    if (token == null) return false;

    Map<String, dynamic> data = {};
    if (rating != null) data['rating'] = rating;
    if (notes != null) data['notes'] = notes;
    if (status != null) data['status'] = status;

    final response = await http.put(
      Uri.parse("$baseUrl/purchased-books/$bookId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    print('Update response: ${response.statusCode} - ${response.body}');
    return response.statusCode == 200;
  }
}
