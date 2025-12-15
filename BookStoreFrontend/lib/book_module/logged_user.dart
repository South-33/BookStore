// To parse this JSON data, do
//
//     final loggedUser = loggedUserFromJson(jsonString);

import 'dart:convert';

LoggedUser loggedUserFromJson(String str) => LoggedUser.fromJson(json.decode(str));

String loggedUserToJson(LoggedUser data) => json.encode(data.toJson());

class LoggedUser {
    User user;
    String token;

    LoggedUser({
        required this.user,
        required this.token,
    });

    factory LoggedUser.fromJson(Map<String, dynamic> json) => LoggedUser(
        user: User.fromJson(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
    };
}

class User {
    int id;
    String name;
    String email;
    String emailVerifiedAt;
    String createdAt;
    String updatedAt;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.emailVerifiedAt,
        required this.createdAt,
        required this.updatedAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"].toString(),
        email: json["email"].toString(),
        emailVerifiedAt: json["email_verified_at"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
