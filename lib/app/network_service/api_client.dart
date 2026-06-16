import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getX;
import 'package:get/get_connect/http/src/status/http_status.dart';

import '../core/config/app_config.dart';
import '../core/connection_manager/connection_manager_controller.dart';
import '../core/constants/app_constants.dart';
import '../core/helper/app_helper.dart';
import '../core/helper/app_widgets.dart';
import '../core/helper/print_log.dart';
import '../core/helper/shared_value_helper.dart';

class ApiClient {
  Dio? dio;

  final _connectionController =
      getX.Get.find<ConnectionManagerController>().obs;

  final String _accessToken = accessToken.$; //todo impl

  ApiClient({customBaseUrl = ''}) {
    BaseOptions options = BaseOptions(
      baseUrl: customBaseUrl != '' ? customBaseUrl : AppConfig.basePath,
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType
          .plain, // To Solve Flutter FormatException: Unexpected character (at character 1)
    );
    dio = Dio(options);
    // dio!.interceptors.clear();
    dio!.interceptors.add(
      QueuedInterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) {
        printLog("On request working");
        return handler.next(options);
      }, onResponse: (Response response, ResponseInterceptorHandler handler) {
        printLog("On response working");
        return handler.next(response);
      }, onError: (DioException err, ErrorInterceptorHandler handler) async {
        if (err.response?.statusCode == 401) {
          AppHelper().logout();

          AppWidgets().getSnackBar(
            title: "Info",
            message: "Response error code: 401",
          );

          //accessToken.$ = "Bearer ${refreshToken.$}";
          //accessToken.save();
          dio?.options.headers["Authorization"] = _accessToken;
          printLog("Refreshing token done");
          return handler.next(err);
        } else if (err.response?.statusCode == 400) {
          var msg = jsonDecode(err.response!.toString())["message"][0] as String;

          //return handler.resolve(err.response!);
          // await AppHelper().logout();
          return handler.reject(err);
          // return handler.next(err);
        } else if (err.response?.statusCode == 503) {
          AppWidgets().getSnackBar(
              title: "Info",
              message: jsonDecode(err.response!.toString())["message"][0]);
          return handler.resolve(err.response!);
        } else if (err.response?.statusCode == 500) {
          await Future.delayed(const Duration(seconds: 1));
          AppHelper().hideLoader();
          AppWidgets()
              .getSnackBar(title: "Info", message: "Response error code: 500");
          return handler.resolve(err.response!);
        } else if (err.response?.statusCode == 204) {
          await Future.delayed(const Duration(seconds: 1));
          AppHelper().hideLoader();
          AppWidgets()
              .getSnackBar(title: "Info", message: "Response error code: 500");
          return handler.resolve(err.response!);
        } else if (err.response?.statusCode == 401 || err.response?.statusCode == 302) {
          // token.$ = "Bearer ${refreshToken.$}";
          //token.save();
          AppHelper().logout();


          AppWidgets().getSnackBar(
              title: "Info",
              message: "Please login again");
          return handler.resolve(err.response!);
        } else {
          AppWidgets().getSnackBar(
            title: "Info",
            message: jsonDecode(err.response.toString())["message"] ?? "",
            // message: jsonDecode(err.response.toString())["message"][0] ?? "",
          );
          return handler.resolve(err.response!);
        }
      }),
    );
  }

  Future<Object?> get(
    // BuildContext context,
    String url,
    retry, {
    Map<String, dynamic>? mQueryParameters,
    // Map<String, dynamic>? headers,
    bool isLoaderRequired = false,
    bool isHeaderRequired = false,
  }) async {
    if (_connectionController.value.isInternetConnected.isTrue) {
      dio?.options.headers["isApp"] = true;
      if (kDebugMode) {
        printLog(
            'URL:${AppConfig.basePath}$url\nQueryParameters: $mQueryParameters');
      }

      //todo make compatible with GetX
      // AppHelper().showLoader();
      /* AppHelper().showLoader();
    AppHelper().hideKeyboard();*/
      if (isLoaderRequired) {
        AppHelper().showLoader();
      }
      try {
        if (isHeaderRequired) {
          dio?.options.headers["Authorization"] = _accessToken;
          // dio?.options.headers["Authorization"] = ApiEndPoints.demoToken;
          dio?.options.headers["language_code"] =
              "en"; // todo need to fix get lang code dynamically later
        }

        var response = await dio?.get(url, queryParameters: mQueryParameters);
        if (kDebugMode) {
          logger.w(
              'URL:  $url\nQueryParameters: $mQueryParameters\nResponse: $response');
        }

        if (isLoaderRequired) {
          await Future.delayed(const Duration(seconds: 1));
          AppHelper().hideLoader();
        }
        return response;
      } on DioException catch (e) {
        handelException(e);
        AppHelper().hideLoader();
        if (!isHeaderRequired &&
            !e.response.toString().contains("<!DOCTYPE html>")) {
          return e.response;
        } else {
          //printCatch(e, retry);
          return null;
        }
      }
    }
    return null;
  }

  Future<Response?> post(
    // context,
    String url,
    data,
    retry, {
    Map<String, dynamic>? headers,
    bool isHeaderRequired = false,
    bool isLoaderRequired = false,
    bool isFormData = false,
    bool isJsonEncodeRequired = true,
    bool isFileUpload = false,
    bool isMultipleFileUpload = false,
    bool isMultipart = false,
    bool isServiceCode = false,
    Map<String, dynamic>? mQueryParameters,
  }) async {
    if (_connectionController.value.isInternetConnected.isTrue) {
      if (isLoaderRequired) {
        AppHelper().showLoader();
      }
      /* AppHelper().showLoader();
    AppHelper().hideKeyboard();*/
      dio?.options.headers["isApp"] = true;

      try {
        if (isHeaderRequired) {
          // token = accessToken.$;
          if (isFileUpload || isMultipleFileUpload) {
            dio?.options.baseUrl = AppConfig.uploadImageBasePath;
          }
          dio?.options.headers["Authorization"] = _accessToken;
          dio?.options.headers["Content-Type"] =
              !isMultipart ? "application/json" : "multipart/form-data";
          if (isServiceCode) {
            dio?.options.headers["service_code"] = "sl_customer";
          }
//application/json-patch+json application/json
        }
        if (kDebugMode) {
          logger.i(
              'before formData URL: ${dio?.options.baseUrl}$url Data:$data token: $_accessToken');
        }
        FormData formData = FormData();

        if (!isMultipleFileUpload) {
          formData = FormData.fromMap(isFormData ? data : {});
        } else if (isMultipleFileUpload) {
          for (var files in data) {
            formData.files.addAll([
              MapEntry("images", await MultipartFile.fromFile(files.path)),
            ]);
          }
        }

        if (kDebugMode) {
          logger.i(
              'URL:${dio?.options.baseUrl}$url Data:$data token: $_accessToken');
        }

        var response = await dio?.post(url,
            // data: formData,
            data: isFormData
                ? formData
                : data == null
                    ? null
                    : isJsonEncodeRequired
                        ? jsonEncode(data)
                        : data,
            queryParameters: mQueryParameters);

        if (kDebugMode) {
          logger.i('URL:  $url\nData: $data\nResponse: $response');
        }

        AppHelper().hideLoader();
        return response;
      } on DioException catch (e) {
        printLog(e.response!);
        // AppWidgets().getSnackBar(
        //     title: "Info",
        //     message: "${jsonDecode(e.response.toString())["message"][0]}",
        //     backgroundColor: AppColors.primaryColor,
        //     colorText: AppColors.whitePure);
        handelException(e);
        AppHelper().hideLoader();
        if (!isHeaderRequired &&
            !e.response.toString().contains("<!DOCTYPE html>")) {
          return e.response;
        } else if (e.response?.statusCode == 403 ||
            e.response?.statusCode == 400) {
          return e.response;
        } else if (e.response?.statusCode == 401) {
          AppHelper().logout();

          //token.$ = "Bearer ${refreshToken.$}";
          //token.save();
          /*    AppWidgets().getSnackBar(
            title: "Info",
            message: "Response error code: 401",
            closeAllSnackbars: false,
          );*/
          return e.response;
        } else {
          //printCatch(e, retry);
          return null;
        }
      }
    } else {
      AppWidgets().getSnackBar(
        title: "Info",
        message: "No internet! Please connect your internet connection.",
      );
    }
    return null;
  }

  Future<Object?> put(
    // BuildContext context,
    String url,
    data,
    retry, {
    Map<String, dynamic>? headers,
    bool isHeaderRequired = true,
    bool isLoaderRequired = false,
    Map<String, dynamic>? mQueryParameters,
  }) async {
    if (_connectionController.value.isInternetConnected.isTrue) {
      dio?.options.headers["isApp"] = true;

      if (isLoaderRequired) {
        AppHelper().showLoader();
      }
      //todo make compatible with GetX
      /* AppHelper().showLoader();
    AppHelper().hideKeyboard();*/
      try {
        if (isHeaderRequired) {
          // token = accessToken.$;
          dio?.options.headers["Authorization"] = _accessToken;
          dio?.options.headers["Content-Type"] = "application/json";
        }
        if (kDebugMode) {
          debugPrint('URL:  $data');
        }
        var response = await dio?.put(
          url,
          data: data,
          // options: Options(contentType: Headers.formUrlEncodedContentType),
          queryParameters: mQueryParameters,
        );
        if (kDebugMode) {
          logger.i('URL:  $url\nData: $data\nResponse: $response');
        }
        AppHelper().hideLoader();
        return response;
      } on DioException catch (e) {
        AppHelper().hideLoader();
        if (!isHeaderRequired &&
            !e.response.toString().contains("<!DOCTYPE html>")) {
          return e.response;
        } else {
          //printCatch(e, retry);
          return null;
        }
      }
    } else {
      AppWidgets().getSnackBar(
        title: "Info",
        message: "No internet! Please connect your internet connection.",
      );
    }
    return null;
  }

  Future<Response?> delete(
    // BuildContext context,
    String url,
    data,
    retry, {
    Map<String, dynamic>? mQueryParameters,
    Map<String, dynamic>? headers,
    bool isHeaderRequired = false,
    bool isLoaderRequired = false,
    bool isFormData = false,
    bool isJsonEncodeRequired = true,
  }) async {
    if (_connectionController.value.isInternetConnected.isTrue) {
      dio?.options.headers["isApp"] = true;

      if (isLoaderRequired) {
        AppHelper().showLoader();
      }

      if (kDebugMode) {
        logger.i(
            'URL:  ${AppConfig.basePath}$url\nQueryParameters: $mQueryParameters');
      }
      //todo make compatible with GetX
      /* AppHelper().showLoader();
    AppHelper().hideKeyboard();*/
      try {
        if (isHeaderRequired) {
          dio?.options.headers["Authorization"] = _accessToken;
          dio?.options.headers["Content-Type"] = "application/json";

          /*  dio?.options.headers["Authorization"] = token;
        dio?.options.headers["language_code"] =
            "en"; // todo need to fix get lang code dynamically later*/
        }
        FormData formData = FormData.fromMap(isFormData ? data : {});

        Response? response = await dio?.delete(url,
            data: data, queryParameters: mQueryParameters);

        logger.w(
            'URL:  $url\nQueryParameters: $mQueryParameters\nResponse: $response');
        // await Future.delayed(const Duration(seconds: 3));
        AppHelper().hideLoader();
        return response;
      } on DioException catch (e) {
        AppHelper().hideLoader();
        if (!isHeaderRequired &&
            !e.response.toString().contains("<!DOCTYPE html>")) {
          return e.response;
        } else {
          //printCatch(e, retry);
          return null;
        }
      }
    } else {
      AppWidgets().getSnackBar(
        title: "Info",
        message: "No internet! Please connect your internet connection.",
      );
    }
    return null;
  }

  Future<void> printCatch(DioException e, retry) async {
    if (kDebugMode) {
      logger.w('printCatch:  ${e.response?.statusCode}');
    }

    if (e.response?.statusCode == HttpStatus.internalServerError) {
      if (kDebugMode) {
        logger
            .w('printCatch: Internal Server Error: ${e.response?.statusCode} ');
      }
    }

    if (e.response?.statusCode == 400) {
    } else if (e.response?.statusCode == 401) {

      AppHelper().logout();

      /*   final jwt = JWT(
        {
          "id": userId.$,
          "user_type": role.$,
          "name": userName.$,
          "email": userEmail.$,
          "avatar": avatarPath.$,
          "avatar_original": avatarOriginal.$,
          "phone": userPhone.$.toString(),
        },
      );
      var regeneratedToken = jwt.sign(SecretKey(AppConfig.secretKey));
      token.$ = "Bearer $regeneratedToken";
      token.save();*/
      // token.$ = "Bearer ${refreshToken.$}";
      // token.save();
    } else if (e.response?.statusCode == 503) {
      AppWidgets().getSnackBar(
          title: "Info",
          message: "Unable Connect with server. Please try again later.");
    } else {
      //TODO clear
      /* AppWidgets().showSimpleDialog(context, "Failed",
          "Something went wrong. Please try again later.", retry);*/
      /*  message:
      "Something went wrong. Please try again later.\nStatus Code: ${e.response != null ? e.response?.statusCode : ""}",
*/
      // FlightUpdateErrorModel error =
      //     flightUpdateErrorModelFromJson(e.response?.data);

      // AppWidgets().getSnackBar(
      //     title: "Failed",
      //     // message: "Something went wrong. Please try again later.",
      //     message: e.response!.data != null ? jsonDecode(e.response!.data)["message"].toString() : "error.message",
      //     waitingTime: 5,
      //     backgroundColor: AppColors.red);
    }
    if (e.response != null) {
      if (kDebugMode) {
        logger.w('Error Response data:  ${e.response?.data}');
        logger.w('Error Response headers:  ${e.response?.headers}');
        logger.w('Error Response statusCode:  ${e.response?.statusCode}');
      }
    } else {
      if (kDebugMode) {
        logger.w('Error Response message:  ${e.message}');
      }
    }
  }

  //todo remove
  Future<dynamic> getDynamicApiData(url) async {
    var response = await Dio().get(
      "${AppConfig.basePath}$url",
    );
    return response;
  }

  handelException(DioException e) {
    /*    try {
      List<ErrorResponse> errorResponse =
          errorResponseFromJson(e.response.toString());
      for (var element in errorResponse) {
        AppWidgets().getSnackBar(
            waitingTime: 4,
            title: element.status,
            message: element.message,
            backgroundColor: AppColors.red);
      }
    } catch (e) {
      printLog("catch e: $e", level: "e");
    }*/
  }
}
