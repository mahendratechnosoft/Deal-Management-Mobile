import 'package:hive/hive.dart';
import 'module_access.dart';
part 'login_response.g.dart';

@HiveType(typeId: 2)
class LoginResponse extends HiveObject {
  @HiveField(0)
  final String jwtToken;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String loginEmail;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String? loginUserName;

  @HiveField(5)
  final String? employeeId;

  @HiveField(6)
  final String? adminId;

  @HiveField(7)
  final ModuleAccess moduleAccess;

  LoginResponse({
    required this.jwtToken,
    required this.userId,
    required this.loginEmail,
    required this.role,
    this.loginUserName,
    this.employeeId,
    this.adminId,
    required this.moduleAccess,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwtToken: json['jwtToken'],
      userId: json['userId'],
      loginEmail: json['loginEmail'],
      role: json['role'],
      loginUserName: json['loginUserName'] ?? 'User',
      employeeId: json['employeeId'],
      adminId: json['adminId'],
      moduleAccess: ModuleAccess.fromJson(json['moduleAccess']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jwtToken': jwtToken,
      'userId': userId,
      'loginEmail': loginEmail,
      'role': role,
      'loginUserName': loginUserName,
      'employeeId': employeeId,
      'adminId': adminId,
      'moduleAccess': moduleAccess.toJson(),
    };
  }
}
