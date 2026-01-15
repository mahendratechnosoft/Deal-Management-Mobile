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

    static bool isEmployeeRestricted(String role) {
    log('🔎 Checking if role is restricted: $role');
    
    // Define roles that are restricted from editing
    final restrictedRoles = [
      'ROLE_EMPLOYEE',    // Regular employees cannot edit
      'employee',         // Lowercase variant
      'EMPLOYEE',         // Uppercase variant
      // Add more restricted roles as needed
    ];
    
    // Check if role is in restricted list
    final isRestricted = restrictedRoles.contains(role);
    log('🔐 Role restricted: $isRestricted');
    
    return isRestricted;
  }
  
  /// Alternative method using cached role
  static bool get isCurrentUserRestricted {
    if (_cachedRole == null) {
      log('⚠️ No cached role found');
      return false; // Default to not restricted if role not set
    }
    
    return isEmployeeRestricted(_cachedRole!);
  }
  
  /// Check if user can edit tasks (convenience method)
  static bool get canEditTasks {
    if (_cachedRole == null) {
      log('⚠️ No cached role found');
      return true; // Default to allow editing if role not set
    }
    
    final allowedRoles = [
      'ROLE_ADMIN',
      'admin',
      'ADMIN',
      // Add other roles with edit permission here
    ];
    
    return allowedRoles.contains(_cachedRole!);
  }

}


