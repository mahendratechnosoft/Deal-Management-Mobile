import 'package:hive/hive.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';

import '../../bloc/user_role.dart';

class AuthLocalStorage {
  static const String _boxName = 'loginResponse';
  static const String _userKey = 'currentUser';

  static Box<LoginResponse> get _box => Hive.box<LoginResponse>(_boxName);

   static Future<void> saveUser(LoginResponse data) async {
    await _box.put(_userKey, data);
  }

  static LoginResponse? getUser() {
    return _box.get(_userKey);
  }

  static bool isLoggedIn() {
    final user = getUser();
    if (user == null || user.jwtToken.isEmpty) {
      return false;
    }
    RoleResolver.setRole(user.role);
    apiInterceptor.updateToken(user.jwtToken);
    return true;
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
