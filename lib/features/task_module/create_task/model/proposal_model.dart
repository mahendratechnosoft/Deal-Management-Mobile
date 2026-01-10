// To parse this JSON data, do
//
//     final proposalModel = proposalModelFromJson(jsonString);

import 'dart:convert';

List<ProposalModel> proposalModelFromJson(String str) => List<ProposalModel>.from(json.decode(str).map((x) => ProposalModel.fromJson(x)));

String proposalModelToJson(List<ProposalModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProposalModel {
    int proposalNumber;
    String formatedProposalNumber;
    CompanyName companyName;
    String proposalId;

    ProposalModel({
        required this.proposalNumber,
        required this.formatedProposalNumber,
        required this.companyName,
        required this.proposalId,
    });

    factory ProposalModel.fromJson(Map<String, dynamic> json) => ProposalModel(
        proposalNumber: json["proposalNumber"],
        formatedProposalNumber: json["formatedProposalNumber"],
        companyName: companyNameValues.map[json["companyName"]]!,
        proposalId: json["proposalId"],
    );

    Map<String, dynamic> toJson() => {
        "proposalNumber": proposalNumber,
        "formatedProposalNumber": formatedProposalNumber,
        "companyName": companyNameValues.reverse[companyName],
        "proposalId": proposalId,
    };
}

enum CompanyName {
    BRIGHT_LINK_INFOTECH_PVT_LTD,
    TCS,
    TECH_SOLUTIONS_PVT_LTD
}

final companyNameValues = EnumValues({
    "BrightLink Infotech Pvt Ltd": CompanyName.BRIGHT_LINK_INFOTECH_PVT_LTD,
    "TCS": CompanyName.TCS,
    "Tech Solutions Pvt Ltd": CompanyName.TECH_SOLUTIONS_PVT_LTD
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
