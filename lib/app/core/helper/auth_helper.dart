import 'package:face_recognition/app/core/helper/shared_value_helper.dart';
import '../../data/remote/model/auth/login_response.dart';

class AuthHelper {
  setUserData(
      LoginResponse loginResponse, String getSRCode, String todayLoginTime) {
    if (loginResponse.token != null) {
      isLoggedIn.$ = true;
      isLoggedIn.save();

      accessToken.$ = "Bearer ${loginResponse.token}";
      accessToken.save();

      userName.$ = loginResponse.user!.name!;
      userName.save();

      userID.$ = loginResponse.user!.id.toString();
      userID.save();

      userEmail.$ = loginResponse.user!.email.toString();
      userEmail.save();

      userPhone.$ = loginResponse.user!.phone.toString();
      userPhone.save();


      userRole.$ = loginResponse.roles.toString().toLowerCase();
      userRole.save();
    }
  }

  clearUserData() {
    isLoggedIn.$ = false;
    isLoggedIn.save();

    accessToken.$ = "";
    accessToken.save();


    userID.$ = "";
    userID.save();

    userName.$ = "";
    userName.save();

    userEmail.$ = "";
    userEmail.save();


    userPhone.$ = "";
    userPhone.save();


    userRole.$ = "";
    userRole.save();

    lastCheckIn.$ = "";
    lastCheckIn.save();
  }

  loadItems() {
    isLoggedIn.load();
    accessToken.load();
    userName.load();
    userID.load();
    userEmail.load();
    userPhone.load();
    lastCheckIn.load();
    userRole.load();
  }
}
