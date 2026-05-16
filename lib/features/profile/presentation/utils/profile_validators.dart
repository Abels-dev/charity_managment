class ProfileValidators {
  static String? requiredText(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    if (text.length < 2) return '$fieldName must be at least 2 characters';
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) return 'Enter a valid phone number';
    return null;
  }

  static String? website(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final hasProtocol = text.startsWith('http://') || text.startsWith('https://');
    if (!hasProtocol) return 'Website must start with http:// or https://';
    if (text.length < 8) return 'Enter a valid website URL';
    return null;
  }
}
