import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

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
  }) async {
    return dio.get('${ApiConstants.allLeadsUrl}/$page/$limit');
  }
}
