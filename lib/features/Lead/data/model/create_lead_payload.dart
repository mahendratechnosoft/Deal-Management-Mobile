class CreateLeadRequest {
  final String companyName;
  final String clientName;
  final String? assignTo;
  final String status;
  final String source;
  final double revenue;
  final String mobileNumber;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? industry;
  final String? priority;
  final String street;
  final String? country;
  final String? state;
  final String? city;
  final String zipCode;
  final String? description;
  final String? followUp;

  CreateLeadRequest({
    required this.companyName,
    required this.clientName,
    this.assignTo,
    this.status = 'New Lead',
    required this.source,
    this.revenue = 0,
    required this.mobileNumber,
    this.phoneNumber,
    this.email,
    this.website,
    this.industry,
    this.priority,
    required this.street,
    this.country,
    this.state,
    this.city,
    required this.zipCode,
    this.description,
    this.followUp,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'assignTo': assignTo,
      'status': status,
      'source': source,
      'clientName': clientName,
      'revenue': revenue,
      'mobileNumber': mobileNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'industry': industry,
      'priority': priority,
      'street': street,
      'country': country,
      'state': state,
      'city': city,
      'zipCode': zipCode,
      'description': description,
      'followUp': followUp,
    }..removeWhere((key, value) => value == null || value == '');
  }

  factory CreateLeadRequest.fromJson(Map<String, dynamic> json) {
    return CreateLeadRequest(
      companyName: json['companyName'] ?? '',
      assignTo: json['assignTo'],
      status: json['status'] ?? 'New Lead',
      source: json['source'] ?? '',
      clientName: json['clientName'] ?? '',
      revenue: json['revenue']?.toDouble() ?? 0,
      mobileNumber: json['mobileNumber'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      industry: json['industry'],
      priority: json['priority'],
      street: json['street'] ?? '',
      country: json['country'],
      state: json['state'],
      city: json['city'],
      zipCode: json['zipCode'] ?? '',
      description: json['description'],
      followUp: json['followUp'],
    );
  }
}