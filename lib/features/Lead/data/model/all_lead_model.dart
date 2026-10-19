class LeadResponseModel {
  final List<String> columnSequence;
  final List<StatusCountModel> statusAndCount;
  final List<LeadModel> leadList;
  final int currentPage;
  final int totalLeads;
  final int totalPages;

  LeadResponseModel({
    required this.columnSequence,
    required this.statusAndCount,
    required this.leadList,
    required this.currentPage,
    required this.totalLeads,
    required this.totalPages,
  });

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
            ? json['data']
            : json;

    final statusRaw = data['statusAndCount'] ??
        data['statusCount'] ??
        data['leadStatusAndCount'] ??
        json['statusAndCount'] ??
        [];

    final listRaw = data['leadList'] ??
        data['leads'] ??
        data['content'] ??
        json['leadList'] ??
        json['leads'] ??
        [];

    final total = data['totalLeads'] ??
        data['totalElements'] ??
        data['totalElement'] ??
        json['totalLeads'] ??
        (listRaw is List ? listRaw.length : 0);

    return LeadResponseModel(
      columnSequence: List<String>.from(data['columnSequence'] ?? json['columnSequence'] ?? []),
      statusAndCount: statusRaw is List
          ? statusRaw.map((e) => StatusCountModel.fromJson(e)).toList()
          : [],
      leadList: listRaw is List
          ? listRaw.map((e) => LeadModel.fromJson(e)).toList()
          : [],
      currentPage: (data['currentPage'] ?? json['currentPage'] ?? 0) is int
          ? (data['currentPage'] ?? json['currentPage'] ?? 0)
          : int.tryParse((data['currentPage'] ?? json['currentPage'] ?? 0).toString()) ?? 0,
      totalLeads: (total is num)
          ? total.toInt()
          : (int.tryParse(total.toString()) ?? 0),
      totalPages: (data['totalPages'] ?? json['totalPages'] ?? 0) is int
          ? (data['totalPages'] ?? json['totalPages'] ?? 0)
          : int.tryParse((data['totalPages'] ?? json['totalPages'] ?? 0).toString()) ?? 0,
    );
  }
}

class StatusCountModel {
  final String status;
  final int count;

  StatusCountModel({
    required this.status,
    required this.count,
  });

  factory StatusCountModel.fromJson(Map<String, dynamic> json) {
    return StatusCountModel(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class LeadModel {
  final String id;
  final String? adminId;
  final String? employeeId;
  final String? assignTo;
  final String status;
  final String? source;
  final String? clientName;
  final String? companyName;
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
  final String? followUp;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final dynamic fields;
  final dynamic columns;

  LeadModel({
    required this.id,
    this.adminId,
    this.employeeId,
    this.assignTo,
    required this.status,
    this.source,
    this.clientName,
    this.companyName,
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
    this.fields,
    this.columns,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      assignTo: json['assignTo'],
      status: json['status'] ?? '',
      source: json['source'],
      clientName: json['clientName'],
      companyName: json['companyName'],
      customerId: json['customerId'],
      revenue: json['revenue'] != null
          ? double.tryParse(json['revenue'].toString())
          : null,
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
      followUp: json['followUp'],
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
      fields: json['fields'],
      columns: json['columns'],
    );
  }
}
