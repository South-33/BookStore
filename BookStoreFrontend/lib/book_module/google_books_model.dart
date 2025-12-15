// Google Books API model

import 'dart:convert';

GoogleBooksResponse googleBooksFromJson(String str) => 
    GoogleBooksResponse.fromJson(json.decode(str));

class GoogleBooksResponse {
  int totalItems;
  List<GoogleBook> items;

  GoogleBooksResponse({
    required this.totalItems,
    required this.items,
  });

  factory GoogleBooksResponse.fromJson(Map<String, dynamic> json) => GoogleBooksResponse(
    totalItems: json["totalItems"] ?? 0,
    items: json["items"] == null 
        ? [] 
        : List<GoogleBook>.from(json["items"].map((x) => GoogleBook.fromJson(x))),
  );
}

class GoogleBook {
  String id;
  VolumeInfo volumeInfo;
  SaleInfo? saleInfo;

  GoogleBook({
    required this.id,
    required this.volumeInfo,
    this.saleInfo,
  });

  factory GoogleBook.fromJson(Map<String, dynamic> json) => GoogleBook(
    id: json["id"] ?? "",
    volumeInfo: VolumeInfo.fromJson(json["volumeInfo"] ?? {}),
    saleInfo: json["saleInfo"] != null ? SaleInfo.fromJson(json["saleInfo"]) : null,
  );
}

class VolumeInfo {
  String title;
  List<String> authors;
  String description;
  String thumbnail;
  String publishedDate;
  int pageCount;
  double averageRating;

  VolumeInfo({
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnail,
    required this.publishedDate,
    required this.pageCount,
    required this.averageRating,
  });

  factory VolumeInfo.fromJson(Map<String, dynamic> json) => VolumeInfo(
    title: json["title"] ?? "Unknown Title",
    authors: json["authors"] != null 
        ? List<String>.from(json["authors"]) 
        : ["Unknown Author"],
    description: json["description"] ?? "No description available.",
    thumbnail: json["imageLinks"]?["thumbnail"] ?? "",
    publishedDate: json["publishedDate"] ?? "",
    pageCount: json["pageCount"] ?? 0,
    averageRating: (json["averageRating"] ?? 0).toDouble(),
  );
}

class SaleInfo {
  String saleability;
  ListPrice? listPrice;

  SaleInfo({
    required this.saleability,
    this.listPrice,
  });

  factory SaleInfo.fromJson(Map<String, dynamic> json) => SaleInfo(
    saleability: json["saleability"] ?? "NOT_FOR_SALE",
    listPrice: json["listPrice"] != null ? ListPrice.fromJson(json["listPrice"]) : null,
  );
}

class ListPrice {
  double amount;
  String currencyCode;

  ListPrice({
    required this.amount,
    required this.currencyCode,
  });

  factory ListPrice.fromJson(Map<String, dynamic> json) => ListPrice(
    amount: (json["amount"] ?? 0).toDouble(),
    currencyCode: json["currencyCode"] ?? "USD",
  );
}
