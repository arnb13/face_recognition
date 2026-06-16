// To parse this JSON data, do
//
//     final leaveCreateResponse = leaveCreateResponseFromJson(jsonString);

import 'dart:convert';

LeaveCreateResponse leaveCreateResponseFromJson(String str) => LeaveCreateResponse.fromJson(json.decode(str));

String leaveCreateResponseToJson(LeaveCreateResponse data) => json.encode(data.toJson());

class LeaveCreateResponse {
  String? status;
  String? message;
  LeaveCreateData? data;

  LeaveCreateResponse({
    this.status,
    this.message,
    this.data,
  });

  factory LeaveCreateResponse.fromJson(Map<String, dynamic> json) => LeaveCreateResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : LeaveCreateData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class LeaveCreateData {
  String? userId;
  DateTime? leaveApplyDate;
  DateTime? leaveFrom;
  DateTime? leaveTo;
  int? leaveAppDays;
  String? reason;
  String? leaveStatus;
  String? leaveApproveDate;
  int? leaveId;

  LeaveCreateData({
    this.userId,
    this.leaveApplyDate,
    this.leaveFrom,
    this.leaveTo,
    this.leaveAppDays,
    this.reason,
    this.leaveStatus,
    this.leaveApproveDate,
    this.leaveId,
  });

  factory LeaveCreateData.fromJson(Map<String, dynamic> json) => LeaveCreateData(
    userId: json["UserID"],
    leaveApplyDate: json["LeaveApplyDate"] == null ? null : DateTime.parse(json["LeaveApplyDate"]),
    leaveFrom: json["LeaveFrom"] == null ? null : DateTime.parse(json["LeaveFrom"]),
    leaveTo: json["LeaveTo"] == null ? null : DateTime.parse(json["LeaveTo"]),
    leaveAppDays: json["LeaveAppDays"],
    reason: json["Reason"],
    leaveStatus: json["LeaveStatus"],
    leaveApproveDate: json["LeaveApproveDate"],
    leaveId: json["LeaveID"],
  );

  Map<String, dynamic> toJson() => {
    "UserID": userId,
    "LeaveApplyDate": leaveApplyDate?.toIso8601String(),
    "LeaveFrom": leaveFrom?.toIso8601String(),
    "LeaveTo": leaveTo?.toIso8601String(),
    "LeaveAppDays": leaveAppDays,
    "Reason": reason,
    "LeaveStatus": leaveStatus,
    "LeaveApproveDate": leaveApproveDate,
    "LeaveID": leaveId,
  };
}
