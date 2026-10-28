class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) return 'Username must be at least 3 characters';
    if (value.trim().length > 30) return 'Username must be at most 30 characters';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Amount must be greater than 0';
    return null;
  }

  static String? optionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Amount cannot be negative';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Enter a valid phone number';
    return null;
  }
}
