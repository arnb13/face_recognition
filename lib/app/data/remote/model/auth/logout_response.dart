import 'dart:convert';

LogoutResponse logoutResponseFromJson(String str) =>
    LogoutResponse.fromJson(json.decode(str));

String logoutResponseToJson(LogoutResponse data) => json.encode(data.toJson());

class LogoutResponse {
  String? message;
  String? status;

  LogoutResponse({
    this.message,
    this.status,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
      };
}
