

class LoginModel {
  final String token;
  final String name;

  LoginModel({
    required this.token,
    required this.name,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'],
      name: json['name'],
    );
  }
}


class ModuleAccess {
  final String moduleAccessId;
  final bool leadAccess;
  final bool leadViewAll;
  final bool leadCreate;
  final bool leadEdit;
  final bool leadDelete;
  // Add more fields as needed

  ModuleAccess({
    required this.moduleAccessId,
    required this.leadAccess,
    required this.leadViewAll,
    required this.leadCreate,
    required this.leadEdit,
    required this.leadDelete,
  });

  factory ModuleAccess.fromJson(Map<String, dynamic> json) {
    return ModuleAccess(
      moduleAccessId: json['moduleAccessId'],
      leadAccess: json['leadAccess'] ?? false,
      leadViewAll: json['leadViewAll'] ?? false,
      leadCreate: json['leadCreate'] ?? false,
      leadEdit: json['leadEdit'] ?? false,
      leadDelete: json['leadDelete'] ?? false,
    );
  }
}

class LoginResponse {
  final String jwtToken;
  final String userId;
  final String loginEmail;
  final String role;
  final String? loginUserName;
  final String? employeeId;
  final String? adminId;
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
      loginUserName: json['loginUserName'],
      employeeId: json['employeeId'],
      adminId: json['adminId'],
      moduleAccess: ModuleAccess.fromJson(json['moduleAccess']),
    );
  }
}

