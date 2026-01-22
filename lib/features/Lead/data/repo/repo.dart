import '../model/lead_status_model.dart';
import '../service/service.dart';

class LeadRepository {
  final LeadService apiService;

  LeadRepository(this.apiService);

  Future<List<LeadStatusModel>> fetchLeadStatus() async {
    final response = await apiService.leadStatus();

    final List data = response.data as List;

    return data
        .map((e) => LeadStatusModel.fromJson(e))
        .toList();
  }
}
