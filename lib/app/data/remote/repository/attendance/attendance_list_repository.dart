import 'package:intl/intl.dart';
import 'package:face_recognition/app/data/remote/model/attendance/attendance_list_response.dart';

import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';

class AttendanceListRepository {
  Future<AttendanceListResponse> submitAttendance(String userID, DateTime date) async {
    var response = await ApiClient().post(
      ApiEndPoints.attendanceList,
      {
        'UserID' : userID,
        'start_date' : DateFormat('yyyy-MM-dd').format(date),
        'end_date' : DateFormat('yyyy-MM-dd').format(date),
      },
      submitAttendance,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );

    return attendanceListResponseFromJson(response.toString());
  }
}