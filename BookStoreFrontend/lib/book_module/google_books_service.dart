import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'google_books_model.dart';

class GoogleBooksService {
  final _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  // Search books 
  Future<GoogleBooksResponse> searchBooks(String query) async {
    final url = "$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20";
    
    http.Response res = await http.get(Uri.parse(url));
    
    if (res.statusCode == 200) {
      return compute(googleBooksFromJson, res.body);
    } else {
      throw Exception("Failed to load books: ${res.statusCode}");
    }
  }

  // Get featured/popular books
  Future<GoogleBooksResponse> getFeaturedBooks() async {
    return searchBooks("bestseller fiction");
  }

  // Get books by category
  Future<GoogleBooksResponse> getBooksByCategory(String category) async {
    return searchBooks("subject:$category");
  }
}
