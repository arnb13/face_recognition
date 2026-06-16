import 'dart:convert';

AttendanceSubmitResponse attendanceSubmitResponseFromJson(String str) => AttendanceSubmitResponse.fromJson(json.decode(str));

String attendanceSubmitResponseToJson(AttendanceSubmitResponse data) => json.encode(data.toJson());

class AttendanceSubmitResponse {
  String? status;
  String? message;
  Data? data;

  AttendanceSubmitResponse({
    this.status,
    this.message,
    this.data,
  });

  factory AttendanceSubmitResponse.fromJson(Map<String, dynamic> json) => AttendanceSubmitResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? userId;
  String? latitude;
  String? longitude;
  String? attendanceType;
  DateTime? entryDate;
  int? attendanceId;

  Data({
    this.userId,
    this.latitude,
    this.longitude,
    this.attendanceType,
    this.entryDate,
    this.attendanceId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["UserID"],
    latitude: json["Latitude"],
    longitude: json["Longitude"],
    attendanceType: json["AttendanceType"],
    entryDate: json["EntryDate"] == null ? null : DateTime.parse(json["EntryDate"]),
    attendanceId: json["AttendanceID"],
  );

  Map<String, dynamic> toJson() => {
    "UserID": userId,
    "Latitude": latitude,
    "Longitude": longitude,
    "AttendanceType": attendanceType,
    "EntryDate": entryDate?.toIso8601String(),
    "AttendanceID": attendanceId,
  };
}
