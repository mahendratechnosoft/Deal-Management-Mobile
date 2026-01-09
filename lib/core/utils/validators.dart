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
}
