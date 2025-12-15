// To parse this JSON data, do
//
//     final registeredUser = registeredUserFromJson(jsonString);

import 'dart:convert';

RegisteredUser registeredUserFromJson(String str) => RegisteredUser.fromJson(json.decode(str));

String registeredUserToJson(RegisteredUser data) => json.encode(data.toJson());

class RegisteredUser {
    String token;
    User user;

    RegisteredUser({
        required this.token,
        required this.user,
    });

    factory RegisteredUser.fromJson(Map<String, dynamic> json) => RegisteredUser(
        token: json["token"].toString(),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    String name;
    String email;
    String updatedAt;
    String createdAt;
    int id;

    User({
        required this.name,
        required this.email,
        required this.updatedAt,
        required this.createdAt,
        required this.id,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"].toString(),
        email: json["email"].toString(),
        updatedAt: json["updated_at"].toString(),
        createdAt: json["created_at"].toString(),
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "updated_at": updatedAt,
        "created_at": createdAt,
        "id": id,
    };
}
