// To parse this JSON data, do
//
//     final invoiceModel = invoiceModelFromJson(jsonString);

import 'dart:convert';

List<InvoiceModel> invoiceModelFromJson(String str) => List<InvoiceModel>.from(
    json.decode(str).map((x) => InvoiceModel.fromJson(x)));

String invoiceModelToJson(List<InvoiceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InvoiceModel {
  CompanyName companyName;
  String formatedInvoiceNumber;
  String invoiceId;
  int invoiceNumber;

  InvoiceModel({
    required this.companyName,
    required this.formatedInvoiceNumber,
    required this.invoiceId,
    required this.invoiceNumber,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        companyName: companyNameValues.map[json["companyName"]]!,
        formatedInvoiceNumber: json["formatedInvoiceNumber"] ?? "NA",
        invoiceId: json["invoiceId"],
        invoiceNumber: json["invoiceNumber"],
      );

  Map<String, dynamic> toJson() => {
        "companyName": companyNameValues.reverse[companyName],
        "formatedInvoiceNumber": formatedInvoiceNumber,
        "invoiceId": invoiceId,
        "invoiceNumber": invoiceNumber,
      };
}

enum CompanyName { BRIGHT_LINK_INFOTECH_PVT_LTD, SHITAL_E_MP, TCS }

final companyNameValues = EnumValues({
  "BrightLink Infotech Pvt Ltd": CompanyName.BRIGHT_LINK_INFOTECH_PVT_LTD,
  "Shital EMp": CompanyName.SHITAL_E_MP,
  "TCS": CompanyName.TCS
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
