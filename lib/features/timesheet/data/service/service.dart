import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

class TimesheetService {
  final Dio dio;

  TimesheetService(this.dio);

  Future<Response> getAllEmpStatus(String date) {
    return dio.get(
      "${ApiConstants.getAllEmpStatusUrl}/$date",
    );
  }

  Future<Response> markAttendance(bool isPresent) {
    return dio.post(
      "${ApiConstants.empAttendanceUrl}/$isPresent",
    );
  }

  Future<Response> empMonthAttendance({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    final res = await dio.get(
      ApiConstants.empmonthAtteUrl,
      options: Options(
        responseType: ResponseType.plain, // always plain
      ),
      queryParameters: {
        "fromDate": toDate,
        "toDate": fromDate,
        "employeeId": employeeId,
      },
    );

     if (res.data is String &&
        (res.data as String).toLowerCase().contains('no attendance')) {
      return Response(
        requestOptions: res.requestOptions,
        statusCode: 200,
        data: {
          "success": true,
          "data": {},
        },
      );
    }

    // ✅ HANDLE: JSON string
    if (res.data is String && (res.data as String).trim().startsWith('{')) {
      return Response(
        requestOptions: res.requestOptions,
        statusCode: res.statusCode,
        data: jsonDecode(res.data),
      );
    }

    return res;
  }

  Future<Response> checkIn(bool checkIn) {
    return dio.post(
      "${ApiConstants.checkInUrl}/$checkIn",
    );
  }

  Future<Map<String, dynamic>> checkInStatus(
      {required String fromDate,
      required String toDate,
      required String employeeId}) async{
    final response =await dio.post(
      ApiConstants.checkInStatusUrl,
      queryParameters: {
        "fromDate": fromDate,
        "toDate": toDate,
        "employeeId": employeeId,
      },
    );
     return Map<String, dynamic>.from(response.data);
  }
}
