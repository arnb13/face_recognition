import 'package:face_recognition/app/data/remote/model/auth/login_response.dart';
import 'package:face_recognition/app/data/remote/model/auth/logout_response.dart';

import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';

class AuthRepository {
  Future<LoginResponse> getUserLogin(String phone, String password,) async {
    var response = await ApiClient().post(
      ApiEndPoints.login,
      {
        "phone": phone,
        "password": password,
      },
      getUserLogin,
      isHeaderRequired: false,
      isLoaderRequired: true,
    );

    return loginResponseFromJson(response.toString());
  }


  Future<LogoutResponse> getUserLogOut() async {
    var response = await ApiClient().post(
      ApiEndPoints.logout,
      {
      },
      getUserLogin,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );

    return logoutResponseFromJson(response.toString());
  }


}
