import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/features/Lead/data/model/create_lead_payload.dart';

import '../model/create_reminder_payload.dart';

class LeadService {
  final Dio dio;

  LeadService(this.dio);

  Future<Response> leadStatus() {
    return dio.get(
      ApiConstants.leadStatusUrl,
    );
  }

  Future<Response> fetchAllLeads({
    required int page,
    required int limit,
    String? leadStatus,
  }) async {
    return dio.get(
      '${ApiConstants.allLeadsUrl}/$page/$limit',
      queryParameters: {
        if (leadStatus != null) 'leadStatus': leadStatus,
      },
    );
  }

  Future<Response> fetchLeadDetails({
    required String? taskId,
  }) async {
    return dio.get(
      '${ApiConstants.allLeadsDetailsUrl}/$taskId',
    );
  }

  Future<Response> fetchActivity({
    required String? taskId,
  }) async {
    return dio.get(
      '${ApiConstants.activityUrl}/$taskId/lead',
    );
  }

  Future<Response> fetchReminder({
    required String? taskId,
  }) async {
    return dio.get(
      '${ApiConstants.reminderUrl}/$taskId',
    );
  }

  Future<Response> createReminder(
      {required CreateReminderRequest request}) async {
    return dio.post(
      data: request.toJson(),
      ApiConstants.createReminderUrl,
    );
  }

  Future<Response> createLead(
      {required CreateLeadRequest request}) async {
    return dio.post(
      data: request.toJson(),
      ApiConstants.createLeadUrl,
    );
  }
}
