import 'package:hive/hive.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';

class AuthLocalStorage {
  static const String _boxName = 'loginResponse';
  static const String _userKey = 'currentUser';

  static Box<LoginResponse> get _box =>
      Hive.box<LoginResponse>(_boxName);

  /// Save login response
  static Future<void> saveUser(LoginResponse data) async {
    await _box.put(_userKey, data);
  }

  /// Get saved user
  static LoginResponse? getUser() {
    return _box.get(_userKey);
  }

  /// Check login
  static bool isLoggedIn() {
    final user = getUser();
    apiInterceptor.updateToken(user!.jwtToken);
    return user.jwtToken.isNotEmpty;
  }

  /// Clear on logout
  static Future<void> clear() async {
    await _box.clear();
    
  }
}
