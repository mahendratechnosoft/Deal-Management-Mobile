import 'dart:developer';

class RoleResolver {
  static String? _cachedRole;

  static void setRole(String role) {
    _cachedRole = role;
    log('✅ Role cached: $_cachedRole');
  }

  static String get rolePath {
    final role = _cachedRole;

    log('🔎 rolePath resolve: $role');

    switch (role) {
      case 'ROLE_ADMIN':
        return 'admin';
      case 'ROLE_EMPLOYEE':
        return 'employee';
      default:
        return 'admin';
    }
  }
}
