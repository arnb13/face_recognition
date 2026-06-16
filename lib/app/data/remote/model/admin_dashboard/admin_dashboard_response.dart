import 'dart:convert';

AdminDashboardResponse adminDashboardResponseFromJson(String str) => AdminDashboardResponse.fromJson(json.decode(str));

String adminDashboardResponseToJson(AdminDashboardResponse data) => json.encode(data.toJson());

class AdminDashboardResponse {
  String? status;
  String? message;
  DateTime? fromDate;
  DateTime? toDate;
  int? totalUser;
  int? totalCheckin;
  int? totalCheckout;
  int? totalLate;
  int? notCheckin;
  List<UserList>? userList;

  AdminDashboardResponse({
    this.status,
    this.message,
    this.fromDate,
    this.toDate,
    this.totalUser,
    this.totalCheckin,
    this.totalCheckout,
    this.totalLate,
    this.notCheckin,
    this.userList,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) => AdminDashboardResponse(
    status: json["status"],
    message: json["message"],
    fromDate: json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
    toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
    totalUser: json["total_user"],
    totalCheckin: json["total_checkin"],
    totalCheckout: json["total_checkout"],
    totalLate: json["total_late"],
    notCheckin: json["not_checkin"],
    userList: json["user_list"] == null ? [] : List<UserList>.from(json["user_list"]!.map((x) => UserList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "from_date": "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
    "to_date": "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
    "total_user": totalUser,
    "total_checkin": totalCheckin,
    "total_checkout": totalCheckout,
    "total_late": totalLate,
    "not_checkin": notCheckin,
    "user_list": userList == null ? [] : List<dynamic>.from(userList!.map((x) => x.toJson())),
  };
}

class UserList {
  int? id;
  String? name;
  String? phone;
  bool? isLate;
  String? lastCheckinLat;
  String? lastCheckinLon;
  DateTime? lastCheckinDatetime;
  DateTime? lastCheckoutDatetime;

  UserList({
    this.id,
    this.name,
    this.phone,
    this.isLate,
    this.lastCheckinLat,
    this.lastCheckinLon,
    this.lastCheckinDatetime,
    this.lastCheckoutDatetime,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    isLate: json["is_late"],
    lastCheckinLat: json["last_checkin_lat"],
    lastCheckinLon: json["last_checkin_lon"],
    lastCheckinDatetime: json["last_checkin_datetime"] == null ? null : DateTime.parse(json["last_checkin_datetime"]),
    lastCheckoutDatetime: json["last_checkout_datetime"] == null ? null : DateTime.parse(json["last_checkout_datetime"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "is_late": isLate,
    "last_checkin_lat": lastCheckinLat,
    "last_checkin_lon": lastCheckinLon,
    "last_checkin_datetime": lastCheckinDatetime?.toIso8601String(),
    "last_checkout_datetime": lastCheckoutDatetime?.toIso8601String(),
  };
}
