// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerModel {
    String companyName;
    String id;

    CustomerModel({
        required this.companyName,
        required this.id,
    });

    factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        companyName: json["companyName"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "companyName": companyName,
        "id": id,
    };
}
