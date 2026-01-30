class LeadResponseModel {
  final List<AllLeadModel> leads;
  final int currentPage;
  final int totalPages;
  final int totalLeads;

  LeadResponseModel({
    required this.leads,
    required this.currentPage,
    required this.totalPages,
    required this.totalLeads,
  });

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadResponseModel(
      leads: (json['leadList'] as List)
          .map((e) => AllLeadModel.fromJson(e))
          .toList(),
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
    );
  }
}

class AllLeadModel {
  final String id;
  final String adminId;
  final String? employeeId;
  final String? assignTo;
  final String status;
  final String? source;
  final String clientName;
  final String companyName;
  final String? customerId;
  final double? revenue;
  final String? mobileNumber;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? industry;
  final String? priority;
  final bool converted;
  final String? street;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? description;
  final DateTime? followUp;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  AllLeadModel({
    required this.id,
    required this.adminId,
    this.employeeId,
    this.assignTo,
    required this.status,
    this.source,
    required this.clientName,
    required this.companyName,
    this.customerId,
    this.revenue,
    this.mobileNumber,
    this.phoneNumber,
    this.email,
    this.website,
    this.industry,
    this.priority,
    required this.converted,
    this.street,
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.description,
    this.followUp,
     this.createdDate,
    this.updatedDate,
  });

  factory AllLeadModel.fromJson(Map<String, dynamic> json) {
    return AllLeadModel(
      id: json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      employeeId: json['employeeId'],
      assignTo: json['assignTo'],
      status: json['status'] ?? '',
      source: json['source'],
      clientName: json['clientName'] ?? '',
      companyName: json['companyName'] ?? '',
      customerId: json['customerId'],
      revenue: (json['revenue'] as num?)?.toDouble(),
      mobileNumber: json['mobileNumber'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      industry: json['industry'],
      priority: json['priority'],
      converted: json['converted'] ?? false,
      street: json['street'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      zipCode: json['zipCode'],
      description: json['description'],
      followUp:
          json['followUp'] != null ? DateTime.tryParse(json['followUp']) : null,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
    );
  }
}
