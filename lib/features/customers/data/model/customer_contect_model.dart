List<CustomerContactModel> customerContactListFromJson(List<dynamic> jsonList) {
  return jsonList
      .map((e) => CustomerContactModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

class CustomerContactModel {
  final String id;
  final String customerId;
  final String name;
  final String? email;
  final String? phone;
  final String? position;
  final bool status;
  final String? userId;

  CustomerContactModel({
    required this.id,
    required this.customerId,
    required this.name,
    this.email,
    this.phone,
    this.position,
    required this.status,
    this.userId,
  });

  /// 🔹 From JSON
  factory CustomerContactModel.fromJson(Map<String, dynamic> json) {
    return CustomerContactModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      status: json['status'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }

  /// 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'status': status,
      'userId': userId,
    };
  }
}
