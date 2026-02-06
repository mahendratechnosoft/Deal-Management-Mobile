class CustomerListModel {
  final int totalCustomers;
  final int totalPages;
  final int currentPage;
  final List<Customer> customerList;

  CustomerListModel({
    required this.totalCustomers,
    required this.totalPages,
    required this.currentPage,
    required this.customerList,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) {
    return CustomerListModel(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      customerList: (json['customerList'] as List<dynamic>?)
              ?.map((e) => Customer.fromJson(e))
              .toList() ??
          [],
    );
  }
}
class Customer {
  final String customerId;
  final String adminId;
  final String? employeeId;
  final String companyName;
  final String phone;
  final String mobile;
  final String? email;
  final String? website;
  final String industry;
  final String? revenue;
  final String? gstin;
  final String? panNumber;

  final String? billingStreet;
  final String? billingCity;
  final String? billingState;
  final String? billingCountry;
  final String? billingZipCode;

  final String? shippingStreet;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final String? shippingZipCode;

  final String? description;
  final bool status;
  final String? userId;

  Customer({
    required this.customerId,
    required this.adminId,
    this.employeeId,
    required this.companyName,
    required this.phone,
    required this.mobile,
    this.email,
    this.website,
    required this.industry,
    this.revenue,
    this.gstin,
    this.panNumber,
    this.billingStreet,
    this.billingCity,
    this.billingState,
    this.billingCountry,
    this.billingZipCode,
    this.shippingStreet,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.shippingZipCode,
    this.description,
    required this.status,
    this.userId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? '',
      adminId: json['adminId'] ?? '',
      employeeId: json['employeeId'],
      companyName: json['companyName'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      website: json['website'],
      industry: json['industry'] ?? '',
      revenue: json['revenue'],
      gstin: json['gstin'],
      panNumber: json['panNumber'],

      billingStreet: json['billingStreet'],
      billingCity: json['billingCity'],
      billingState: json['billingState'],
      billingCountry: json['billingCountry'],
      billingZipCode: json['billingZipCode'],

      shippingStreet: json['shippingStreet'],
      shippingCity: json['shippingCity'],
      shippingState: json['shippingState'],
      shippingCountry: json['shippingCountry'],
      shippingZipCode: json['shippingZipCode'],

      description: json['description'],
      status: json['status'] ?? false,
      userId: json['userId'],
    );
  }
}
