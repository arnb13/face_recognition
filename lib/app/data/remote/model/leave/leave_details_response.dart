import 'dart:convert';

LeaveDetailsResponse leaveDetailsResponseFromJson(String str) => LeaveDetailsResponse.fromJson(json.decode(str));

String leaveDetailsResponseToJson(LeaveDetailsResponse data) => json.encode(data.toJson());

class LeaveDetailsResponse {
  String? status;
  String? message;
  LeaveDetailsData? data;

  LeaveDetailsResponse({
    this.status,
    this.message,
    this.data,
  });

  factory LeaveDetailsResponse.fromJson(Map<String, dynamic> json) => LeaveDetailsResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : LeaveDetailsData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class LeaveDetailsData {
  int? leaveId;
  String? userId;
  DateTime? leaveApplyDate;
  DateTime? leaveFrom;
  DateTime? leaveTo;
  int? leaveAppDays;
  String? reason;
  String? leaveStatus;
  DateTime? leaveApproveDate;
  User? user;

  LeaveDetailsData({
    this.leaveId,
    this.userId,
    this.leaveApplyDate,
    this.leaveFrom,
    this.leaveTo,
    this.leaveAppDays,
    this.reason,
    this.leaveStatus,
    this.leaveApproveDate,
    this.user,
  });

  factory LeaveDetailsData.fromJson(Map<String, dynamic> json) => LeaveDetailsData(
    leaveId: json["LeaveID"],
    userId: json["UserID"],
    leaveApplyDate: json["LeaveApplyDate"] == null ? null : DateTime.parse(json["LeaveApplyDate"]),
    leaveFrom: json["LeaveFrom"] == null ? null : DateTime.parse(json["LeaveFrom"]),
    leaveTo: json["LeaveTo"] == null ? null : DateTime.parse(json["LeaveTo"]),
    leaveAppDays: json["LeaveAppDays"],
    reason: json["Reason"],
    leaveStatus: json["LeaveStatus"],
    leaveApproveDate: json["LeaveApproveDate"] == null ? null : DateTime.parse(json["LeaveApproveDate"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "LeaveID": leaveId,
    "UserID": userId,
    "LeaveApplyDate": leaveApplyDate?.toIso8601String(),
    "LeaveFrom": leaveFrom?.toIso8601String(),
    "LeaveTo": leaveTo?.toIso8601String(),
    "LeaveAppDays": leaveAppDays,
    "Reason": reason,
    "LeaveStatus": leaveStatus,
    "LeaveApproveDate": leaveApproveDate?.toIso8601String(),
    "user": user?.toJson(),
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
