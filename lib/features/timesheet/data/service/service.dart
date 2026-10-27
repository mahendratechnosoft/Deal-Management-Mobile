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

  Future<Response> getCalendar({
    required String startDate,
    required String endDate,
  }) {
    return dio.get(
      ApiConstants.calendarUrl,
      queryParameters: {
        "startDate": startDate,
        "endDate": endDate,
      },
    );
  }

  Future<Response> getEmployeeNameAndId({bool excludeMe = false}) {
    return dio.get(
      ApiConstants.assignUrl,
      queryParameters: {
        "excludeMe": excludeMe,
      },
    );
  }

  Future<Response> empMonthAttendance({
    required String fromDate,
    required String toDate,
    String? employeeId,
  }) async {
    final Map<String, dynamic> queryParams = {
      "fromDate": fromDate,
      "toDate": toDate,
    };
    if (employeeId != null && employeeId.isNotEmpty) {
      queryParams["employeeId"] = employeeId;
    }

    final res = await dio.get(
      ApiConstants.empmonthAtteUrl,
      options: Options(
        responseType: ResponseType.plain, // plain to safely handle string error/empty message
      ),
      queryParameters: queryParams,
    );

    if (res.data is String &&
        (res.data as String).toLowerCase().contains('no attendance')) {
      return Response(
        requestOptions: res.requestOptions,
        statusCode: 200,
        data: <String, dynamic>{},
      );
    }

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

  Future<dynamic> checkInStatus({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    // Uses getAttendanceBetween for single employee to get today's punches
    return empMonthAttendance(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );
  }
}
