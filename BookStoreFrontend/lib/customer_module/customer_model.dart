// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
    String currentPage;
    List<Customer> data;
    String firstPageUrl;
    String from;
    String lastPage;
    String lastPageUrl;
    List<Link> links;
    String nextPageUrl;
    String path;
    String perPage;
    String prevPageUrl;
    String to;
    String total;

    CustomerModel({
        required this.currentPage,
        required this.data,
        required this.firstPageUrl,
        required this.from,
        required this.lastPage,
        required this.lastPageUrl,
        required this.links,
        required this.nextPageUrl,
        required this.path,
        required this.perPage,
        required this.prevPageUrl,
        required this.to,
        required this.total,
    });

    factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        currentPage: json["current_page"].toString(),
        data: List<Customer>.from(json["data"].map((x) => Customer.fromJson(x))),
        firstPageUrl: json["first_page_url"].toString(),
        from: json["from"].toString(),
        lastPage: json["last_page"].toString(),
        lastPageUrl: json["last_page_url"].toString(),
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"].toString(),
        path: json["path"].toString(),
        perPage: json["per_page"].toString(),
        prevPageUrl: json["prev_page_url"].toString(),
        to: json["to"].toString(),
        total: json["total"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
    };
}

class Customer {
    int id;
    String name;
    String email;
    String tel;
    String createdAt;
    String updatedAt;

    Customer({
        required this.id,
        required this.name,
        required this.email,
        required this.tel,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"].toString(),
        email: json["email"].toString(),
        tel: json["tel"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "tel": tel,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}

class Link {
    String? url;
    String label;
    String? page;
    String active;

    Link({
        required this.url,
        required this.label,
        required this.page,
        required this.active,
    });

    factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"].toString(),
        label: json["label"].toString(),
        page: json["page"].toString(),
        active: json["active"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "page": page,
        "active": active,
    };
}
