import 'dart:convert';

LeaveListResponse leaveListResponseFromJson(String str) => LeaveListResponse.fromJson(json.decode(str));

String leaveListResponseToJson(LeaveListResponse data) => json.encode(data.toJson());

class LeaveListResponse {
  String? status;
  String? message;
  int? totalLeave;
  int? totalPending;
  int? totalReject;
  int? totalApprove;
  List<LeaveListData>? data;

  LeaveListResponse({
    this.status,
    this.message,
    this.totalLeave,
    this.totalPending,
    this.totalReject,
    this.totalApprove,
    this.data,
  });

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) => LeaveListResponse(
    status: json["status"],
    message: json["message"],
    totalLeave: json["TotalLeave"],
    totalPending: json["TotalPending"],
    totalReject: json["TotalReject"],
    totalApprove: json["TotalApprove"],
    data: json["data"] == null ? [] : List<LeaveListData>.from(json["data"]!.map((x) => LeaveListData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "TotalLeave": totalLeave,
    "TotalPending": totalPending,
    "TotalReject": totalReject,
    "TotalApprove": totalApprove,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class LeaveListData {
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

  LeaveListData({
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

  factory LeaveListData.fromJson(Map<String, dynamic> json) => LeaveListData(
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

  User({
    this.id,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}
