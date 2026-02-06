// lib/features/customers/domain/models/customer_model.dart
class CustomerModel {
  final String companyName;
  final String email;
  final String phone;
  final String mobile;
  final String website;
  final String industry;
  final String revenue;
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
  final String password;
  final String loginEmail;
  final String? gstin;
  final String? panNumber;

  CustomerModel({
    required this.companyName,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.website,
    required this.industry,
    required this.revenue,
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
    required this.password,
    required this.loginEmail,
    this.gstin,
    this.panNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'phone': phone,
      'mobile': mobile,
      'website': website,
      'industry': industry,
      'revenue': revenue,
      'billingStreet': billingStreet,
      'billingCity': billingCity,
      'billingState': billingState,
      'billingCountry': billingCountry,
      'billingZipCode': billingZipCode,
      'shippingStreet': shippingStreet,
      'shippingCity': shippingCity,
      'shippingState': shippingState,
      'shippingCountry': shippingCountry,
      'shippingZipCode': shippingZipCode,
      'description': description,
      'password': password,
      'loginEmail': loginEmail,
      if (gstin != null) 'gstin': gstin,
      if (panNumber != null) 'panNumber': panNumber,
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      website: json['website'] ?? '',
      industry: json['industry'] ?? '',
      revenue: json['revenue'] ?? '',
      billingStreet: json['billingStreet'] ?? '',
      billingCity: json['billingCity'] ?? '',
      billingState: json['billingState'] ?? '',
      billingCountry: json['billingCountry'] ?? '',
      billingZipCode: json['billingZipCode'] ?? '',
      shippingStreet: json['shippingStreet'] ?? '',
      shippingCity: json['shippingCity'] ?? '',
      shippingState: json['shippingState'] ?? '',
      shippingCountry: json['shippingCountry'] ?? '',
      shippingZipCode: json['shippingZipCode'] ?? '',
      description: json['description'] ?? '',
      password: json['password'] ?? '',
      loginEmail: json['loginEmail'] ?? '',
      gstin: json['gstin'],
      panNumber: json['panNumber'],
    );
  }
}

//
// lib/features/customers/domain/models/customer_form_model.dart// lib/features/customers/create_customer/bloc/model/customer_payload_model.dart
class CustomerFormModel {
  String? companyName;
  String? email;
  String? primaryNumber;
  String? secondaryNumber;
  String? website;
  String? industry;
  String? annualRevenue;
  String? streetAddress;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? gstin;
  String? panNumber;
  String? description;
  String? password;
  String? loginEmail;
  bool useSameAddress = true;

  CustomerFormModel({
    this.companyName,
    this.email,
    this.primaryNumber,
    this.secondaryNumber,
    this.website,
    this.industry,
    this.annualRevenue,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.gstin,
    this.panNumber,
    this.description,
    this.password,
    this.loginEmail,
    this.useSameAddress = true,
  });

  CustomerModel toCustomerModel() {
    return CustomerModel(
      companyName: companyName ?? '',
      email: email ?? '',
      phone: primaryNumber ?? '',
      mobile: secondaryNumber ?? '',
      website: website ?? '',
      industry: industry ?? '',
      revenue: annualRevenue ?? '',
      billingStreet: streetAddress ?? '',
      billingCity: city ?? '',
      billingState: state ?? '',
      billingCountry: country ?? '',
      billingZipCode: zipCode ?? '',
      shippingStreet: useSameAddress ? (streetAddress ?? '') : '',
      shippingCity: useSameAddress ? (city ?? '') : '',
      shippingState: useSameAddress ? (state ?? '') : '',
      shippingCountry: useSameAddress ? (country ?? '') : '',
      shippingZipCode: useSameAddress ? (zipCode ?? '') : '',
      description: description ?? '',
      password: password ?? '',
      loginEmail: loginEmail ?? '',
      gstin: gstin,
      panNumber: panNumber,
    );
  }

  // Add this method
  bool isFormValid() {
    return companyName?.isNotEmpty == true &&
        primaryNumber?.isNotEmpty == true &&
        industry?.isNotEmpty == true;
  }

  // Optional: Add a method to check if form is valid for display purposes
  Map<String, bool> getRequiredFieldsStatus() {
    return {
      'companyName': companyName?.isNotEmpty == true,
      'primaryNumber': primaryNumber?.isNotEmpty == true,
      'industry': industry?.isNotEmpty == true,
      'streetAddress': streetAddress?.isNotEmpty == true,
      'city': city?.isNotEmpty == true,
      'state': state?.isNotEmpty == true,
      'country': country?.isNotEmpty == true,
      'zipCode': zipCode?.isNotEmpty == true,
    };
  }
}
