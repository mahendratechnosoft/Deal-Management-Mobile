// To parse this JSON data, do
//
//     final proformModel = proformModelFromJson(jsonString);

import 'dart:convert';

List<ProformModel> proformModelFromJson(String str) => List<ProformModel>.from(json.decode(str).map((x) => ProformModel.fromJson(x)));

String proformModelToJson(List<ProformModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProformModel {
    CompanyName companyName;
    String formatedProformaInvoiceNumber;
    String proformaInvoiceId;
    int proformaInvoiceNumber;

    ProformModel({
        required this.companyName,
        required this.formatedProformaInvoiceNumber,
        required this.proformaInvoiceId,
        required this.proformaInvoiceNumber,
    });

    factory ProformModel.fromJson(Map<String, dynamic> json) => ProformModel(
        companyName: companyNameValues.map[json["companyName"]]!,
        formatedProformaInvoiceNumber: json["formatedProformaInvoiceNumber"],
        proformaInvoiceId: json["proformaInvoiceId"],
        proformaInvoiceNumber: json["proformaInvoiceNumber"],
    );

    Map<String, dynamic> toJson() => {
        "companyName": companyNameValues.reverse[companyName],
        "formatedProformaInvoiceNumber": formatedProformaInvoiceNumber,
        "proformaInvoiceId": proformaInvoiceId,
        "proformaInvoiceNumber": proformaInvoiceNumber,
    };
}

enum CompanyName {
    BRIGHT_LINK_INFOTECH_PVT_LTD,
    DFDF,
    SHITAL_E_MP,
    TCS
}

final companyNameValues = EnumValues({
    "BrightLink Infotech Pvt Ltd": CompanyName.BRIGHT_LINK_INFOTECH_PVT_LTD,
    "dfdf": CompanyName.DFDF,
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
