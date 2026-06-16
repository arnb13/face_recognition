import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:face_recognition/app/data/remote/model/leave/leave_approval_response.dart';
import 'package:face_recognition/app/data/remote/model/leave/leave_create_response.dart';
import 'package:face_recognition/app/data/remote/model/leave/leave_details_response.dart';
import '../../../../network_service/api_client.dart';
import '../../../../network_service/api_end_points.dart';
import '../../model/leave/leave_list_response.dart';

class LeaveRepository {
  Future<LeaveCreateResponse> submitLeave(DateTimeRange date, String reason) async {
    var response = await ApiClient().post(
      ApiEndPoints.leaveCreate,
      {
        'LeaveFrom' : DateFormat('yyyy-MM-dd').format(date.start),
        'LeaveTo' : DateFormat('yyyy-MM-dd').format(date.end),
        'Reason' : reason
      },
      submitLeave,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );
    return leaveCreateResponseFromJson(response.toString());
  }



  Future<LeaveListResponse> getLeaveList(DateTimeRange date) async {
    var response = await ApiClient().post(
      ApiEndPoints.leaveList,
      {
        'start_date' : DateFormat('yyyy-MM-dd').format(date.start),
        'end_date' : DateFormat('yyyy-MM-dd').format(date.end),
      },
      getLeaveList,
      isHeaderRequired: true,
      isLoaderRequired: false,
      isFormData: true
    );
    return leaveListResponseFromJson(response.toString());
  }


  Future<LeaveDetailsResponse> getLeaveDetails(String leaveID) async {
    var response = await ApiClient().get(
      ApiEndPoints.leaveDetails + leaveID,
      getLeaveDetails,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );
    return leaveDetailsResponseFromJson(response.toString());
  }


  Future<LeaveApprovalResponse> submitLeaveApproval(String leaveID, bool isApproved) async {
    var response = await ApiClient().post(
      ApiEndPoints.leaveApprove,
      {
        'LeaveID' : leaveID,
        'IsApprove' : isApproved ? '1' : '0',
      },
      submitLeaveApproval,
      isHeaderRequired: true,
      isLoaderRequired: true,
    );
    return leaveApprovalResponseFromJson(response.toString());
  }
}