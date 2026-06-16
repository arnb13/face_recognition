import 'package:face_recognition/app/data/remote/model/user/user_list_response.dart';
import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';

class UserListRepository {
  Future<UserListResponse> getUserList() async {
    var response = await ApiClient().get(
      ApiEndPoints.userList,
      getUserList,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );

    return userListResponseFromJson(response.toString());
  }
}