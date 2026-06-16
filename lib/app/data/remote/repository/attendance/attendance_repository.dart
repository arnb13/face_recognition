import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:face_recognition/app/core/helper/shared_value_helper.dart';
import 'package:face_recognition/app/data/remote/model/attendance/attendance_submit_response.dart';
import 'package:dio/dio.dart';
import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';

class AttendanceRepository {
  Future<AttendanceSubmitResponse> submitAttendance(String lat, String lon, String type, String image) async {
    Map<String, dynamic> data = {
      "UserID": userID.$,
      "Latitude": lat,
      "Longitude": lon,
      "AttendanceType": type,
      "EntryDate": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
    };

    if (image.isNotEmpty) {
      data['Image'] = await MultipartFile.fromFile(
        image,
        filename: p.basename(image),
      );
    }

    var response = await ApiClient().post(
      ApiEndPoints.attendance,
      data,
      submitAttendance,
      isHeaderRequired: true,
      isLoaderRequired: true,
      isFormData: image.isNotEmpty ? true : false,
      isMultipart: image.isNotEmpty ? true : false,
      isFileUpload: image.isNotEmpty ? true : false,
    );

    return attendanceSubmitResponseFromJson(response.toString());
  }
}