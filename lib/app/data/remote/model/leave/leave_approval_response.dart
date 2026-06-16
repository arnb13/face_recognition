import 'dart:convert';

LeaveApprovalResponse leaveApprovalResponseFromJson(String str) => LeaveApprovalResponse.fromJson(json.decode(str));

String leaveApprovalResponseToJson(LeaveApprovalResponse data) => json.encode(data.toJson());

class LeaveApprovalResponse {
  String? status;
  String? message;
  LeaveApprovalData? data;

  LeaveApprovalResponse({
    this.status,
    this.message,
    this.data,
  });

  factory LeaveApprovalResponse.fromJson(Map<String, dynamic> json) => LeaveApprovalResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : LeaveApprovalData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class LeaveApprovalData {
  int? leaveId;
  String? userId;
  DateTime? leaveApplyDate;
  DateTime? leaveFrom;
  DateTime? leaveTo;
  int? leaveAppDays;
  String? reason;
  String? leaveStatus;
  DateTime? leaveApproveDate;

  LeaveApprovalData({
    this.leaveId,
    this.userId,
    this.leaveApplyDate,
    this.leaveFrom,
    this.leaveTo,
    this.leaveAppDays,
    this.reason,
    this.leaveStatus,
    this.leaveApproveDate,
  });

  factory LeaveApprovalData.fromJson(Map<String, dynamic> json) => LeaveApprovalData(
    leaveId: json["LeaveID"],
    userId: json["UserID"],
    leaveApplyDate: json["LeaveApplyDate"] == null ? null : DateTime.parse(json["LeaveApplyDate"]),
    leaveFrom: json["LeaveFrom"] == null ? null : DateTime.parse(json["LeaveFrom"]),
    leaveTo: json["LeaveTo"] == null ? null : DateTime.parse(json["LeaveTo"]),
    leaveAppDays: json["LeaveAppDays"],
    reason: json["Reason"],
    leaveStatus: json["LeaveStatus"],
    leaveApproveDate: json["LeaveApproveDate"] == null ? null : DateTime.parse(json["LeaveApproveDate"]),
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
  };
}
