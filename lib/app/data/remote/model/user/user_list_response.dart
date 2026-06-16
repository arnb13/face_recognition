import 'dart:convert';

UserListResponse userListResponseFromJson(String str) => UserListResponse.fromJson(json.decode(str));

String userListResponseToJson(UserListResponse data) => json.encode(data.toJson());

class UserListResponse {
  String? status;
  String? message;
  List<UserData>? data;

  UserListResponse({
    this.status,
    this.message,
    this.data,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) => UserListResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<UserData>.from(json["data"]!.map((x) => UserData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class UserData {
  String? id;
  String? name;
  String? email;
  String? phone;

  UserData({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"].toString(),
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
