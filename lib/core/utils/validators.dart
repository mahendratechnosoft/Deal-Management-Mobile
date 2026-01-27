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

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.length < 3) return 'Minimum 3 characters required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
      return 'Enter valid 10 digit number';
    }
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
