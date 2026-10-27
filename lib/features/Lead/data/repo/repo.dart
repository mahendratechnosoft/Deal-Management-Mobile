import 'dart:convert';
import 'package:xpertbiz/features/Lead/data/model/activity_log_model.dart';
import 'package:xpertbiz/features/Lead/data/model/create_lead_payload.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/Lead/data/model/reminder_model.dart';
import '../model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/model/create_reminder_payload.dart';
import '../model/lead_status_model.dart';
import '../service/service.dart';

class LeadRepository {
  final LeadService apiService;

  LeadRepository(this.apiService);

  Future<List<LeadStatusModel>> fetchLeadStatus() async {
    final response = await apiService.leadStatus();
    final dynamic rawData = response.data;
    final dynamic listData = rawData is String
        ? jsonDecode(rawData)
        : (rawData is List ? rawData : (rawData is Map && rawData['data'] is List ? rawData['data'] : []));
    if (listData is List) {
      return listData.map((e) => LeadStatusModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<LeadResponseModel> fecthAllLeads({
    required int page,
    required int limit,
    String? status,
    String? search,
  }) async {
    final res = await apiService.fetchAllLeads(
      page: page,
      limit: limit,
      leadStatus: status,
      search: search,
    );
    final dynamic rawData = res.data;
    final Map<String, dynamic> data = rawData is String
        ? jsonDecode(rawData)
        : (rawData is Map<String, dynamic> ? rawData : {});
    return LeadResponseModel.fromJson(data);
  }

  Future<LeadDetailsModel> fecthLeadDetails({required String? taskId}) async {
    final res = await apiService.fetchLeadDetails(taskId: taskId);
    return LeadDetailsModel.fromJson(res.data);
  }

  Future<List<ActivityLogModel>> fetchActivity({String? taskId}) async {
    final res = await apiService.fetchActivity(taskId: taskId);
    return (res.data as List).map((e) => ActivityLogModel.fromJson(e)).toList();
  }

  Future<List<ReminderModel>> fetchReminder({String? taskId}) async {
    final res = await apiService.fetchReminder(taskId: taskId);
    return (res.data as List).map((e) => ReminderModel.fromJson(e)).toList();
  }

  Future<bool> createReminder({required CreateReminderRequest request}) async {
    final res = await apiService.createReminder(request: request);
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<dynamic> createLead(
      {required CreateLeadRequest request, required bool edit}) async {
    final res = await apiService.createLead(request: request, edit: edit);
    return res.data;
  }

  Future<dynamic> deleteLead(String taskId) async {
    final res = await apiService.deletelead(taskId);
    return res.data;
  }
}
