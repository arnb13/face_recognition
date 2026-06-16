// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String? status;
  String? message;
  String? token;
  User? user;
  String? roles;

  LoginResponse({
    this.status,
    this.message,
    this.token,
    this.user,
    this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    message: json["message"],
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    roles: json["roles"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "token": token,
    "user": user?.toJson(),
    "roles": roles,
  };
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
  };
}
