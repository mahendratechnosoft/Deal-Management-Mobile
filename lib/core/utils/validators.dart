class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    // Basic email regex pattern
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name is required';
    }
    if (value.length < 2) {
      return 'Company name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateGSTIN(String? value) {
    if (value != null && value.isNotEmpty) {
      final gstinRegex =
          RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
      if (!gstinRegex.hasMatch(value)) {
        return 'Enter a valid GSTIN';
      }
    }
    return null;
  }

  static String? validatePAN(String? value) {
    if (value != null && value.isNotEmpty) {
      final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
      if (!panRegex.hasMatch(value)) {
        return 'Enter a valid PAN number';
      }
    }
    return null;
  }

  static String? validateRevenue(String? value) {
    if (value != null && value.isNotEmpty) {
      final revenueRegex = RegExp(r'^[0-9]+$');
      if (!revenueRegex.hasMatch(value)) {
        return 'Enter valid revenue number';
      }
    }
    return null;
  }

  // Password validation (optional)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? number(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  static String? description(
    String? value, {
    int min = 100,
    int max = 200,
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min || value.length > max) {
      return 'Description must be $min–$max characters';
    }
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.length < 3) return 'Minimum 3 characters required';
    return null;
  }

  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!Uri.tryParse(v)!.isAbsolute) return 'Invalid URL';
    return null;
  }

  static String? zip(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.length < 4) return 'Invalid ZIP code';
    return null;
  }
}
