import 'package:intl/intl.dart';
import 'package:face_recognition/app/data/remote/model/admin_dashboard/admin_dashboard_response.dart';
import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';

class AdminDashboardRepository {
  Future<AdminDashboardResponse> getAdminDashboardData(DateTime date) async {
    var response = await ApiClient().post(
      ApiEndPoints.adminDashboard,
      {
        "from_date": DateFormat('yyyy-MM-dd').format(date),
        "to_date": DateFormat('yyyy-MM-dd').format(date),
      },
      getAdminDashboardData,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );
    return adminDashboardResponseFromJson(response.toString());
  }
}