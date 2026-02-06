class UpdateCustomerRequest {
  final String customerId;
  final String adminId;
  final String? employeeId;
  final String companyName;
  final String phone;
  final String mobile;
  final String? email;
  final String website;
  final String industry;
  final String revenue;
  final String? gstin;
  final String? panNumber;
  final String billingStreet;
  final String billingCity;
  final String billingState;
  final String billingCountry;
  final String billingZipCode;
  final String shippingStreet;
  final String shippingCity;
  final String shippingState;
  final String shippingCountry;
  final String shippingZipCode;
  final String description;
  final bool status;
  final String userId;
  final int password;
  final String loginEmail;
  final bool active;

  UpdateCustomerRequest({
    required this.customerId,
    required this.adminId,
    this.employeeId,
    required this.companyName,
    required this.phone,
    required this.mobile,
    this.email,
    required this.website,
    required this.industry,
    required this.revenue,
    this.gstin,
    this.panNumber,
    required this.billingStreet,
    required this.billingCity,
    required this.billingState,
    required this.billingCountry,
    required this.billingZipCode,
    required this.shippingStreet,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingCountry,
    required this.shippingZipCode,
    required this.description,
    required this.status,
    required this.userId,
    required this.password,
    required this.loginEmail,
    required this.active,
  });

  /// 🔁 FROM JSON
  factory UpdateCustomerRequest.fromJson(Map<String, dynamic> json) {
    return UpdateCustomerRequest(
      customerId: json['customerId'],
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      companyName: json['companyName'],
      phone: json['phone'],
      mobile: json['mobile'],
      email: json['email'],
      website: json['website'],
      industry: json['industry'],
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
      status: json['status'],
      userId: json['userId'],
      password: json['password'],
      loginEmail: json['loginEmail'],
      active: json['active'],
    );
  }

  /// 🔁 TO JSON (FOR API CALL)
  Map<String, dynamic> toJson() {
    return {
      "customerId": customerId,
      "adminId": adminId,
      "employeeId": employeeId,
      "companyName": companyName,
      "phone": phone,
      "mobile": mobile,
      "email": email,
      "website": website,
      "industry": industry,
      "revenue": revenue,
      "gstin": gstin,
      "panNumber": panNumber,
      "billingStreet": billingStreet,
      "billingCity": billingCity,
      "billingState": billingState,
      "billingCountry": billingCountry,
      "billingZipCode": billingZipCode,
      "shippingStreet": shippingStreet,
      "shippingCity": shippingCity,
      "shippingState": shippingState,
      "shippingCountry": shippingCountry,
      "shippingZipCode": shippingZipCode,
      "description": description,
      "status": status,
      "userId": userId,
      "password": password,
      "loginEmail": loginEmail,
      "active": active,
    };
  }
}
