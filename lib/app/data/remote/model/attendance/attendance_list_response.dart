import 'dart:convert';

AttendanceListResponse attendanceListResponseFromJson(String str) => AttendanceListResponse.fromJson(json.decode(str));

String attendanceListResponseToJson(AttendanceListResponse data) => json.encode(data.toJson());

class AttendanceListResponse {
  String? status;
  String? message;
  List<AttendanceData>? data;

  AttendanceListResponse({
    this.status,
    this.message,
    this.data,
  });

  factory AttendanceListResponse.fromJson(Map<String, dynamic> json) => AttendanceListResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<AttendanceData>.from(json["data"]!.map((x) => AttendanceData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class AttendanceData {
  int? attendanceId;
  String? userId;
  String? userName;
  String? userEmail;
  String? latitude;
  String? longitude;
  String? attendanceType;
  String? image;
  DateTime? entryDate;

  AttendanceData({
    this.attendanceId,
    this.userId,
    this.userName,
    this.userEmail,
    this.latitude,
    this.longitude,
    this.attendanceType,
    this.image,
    this.entryDate,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
    attendanceId: json["AttendanceID"],
    userId: json["UserID"],
    userName: json["UserName"],
    userEmail: json["UserEmail"],
    latitude: json["Latitude"],
    longitude: json["Longitude"],
    attendanceType: json["AttendanceType"],
    image: json["Image"],
    entryDate: json["EntryDate"] == null ? null : DateTime.parse(json["EntryDate"]),
  );

  Map<String, dynamic> toJson() => {
    "AttendanceID": attendanceId,
    "UserID": userId,
    "UserName": userName,
    "UserEmail": userEmail,
    "Latitude": latitude,
    "Longitude": longitude,
    "AttendanceType": attendanceType,
    "Image": image,
    "EntryDate": entryDate?.toIso8601String(),
  };
}
