/// A utility class for common text field validations.
class TextFieldValidator {
  TextFieldValidator._();

  /// Validates that the input is not empty.
  static String? validateNotEmpty(
    String? value, {
    String errorMessage = 'This field cannot be empty',
  }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input as a valid name.
  static String? validateName(
    String? value, {
    String errorMessage = 'Please enter a valid name',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    // Regex to allow letters, spaces, hyphens, and apostrophes.
    // Ensures the name starts with a letter and any separator is followed by another letter.
    final RegExp nameRegExp = RegExp(r"^[a-zA-Z]+(?:[\s-'][a-zA-Z]+)*$");

    if (!nameRegExp.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input as a valid email address format.
  static String? validateEmail(
    String? value, {
    String errorMessage = 'Please enter a valid email address',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Validates password strength based on a minimum length.
  static String? validatePassword(
    String? value, {
    int minLength = 8,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < minLength) {
      return errorMessage ??
          'Password must be at least $minLength characters long';
    }
    return null;
  }

  /// Validates that two string values match (e.g., password confirmation).
  static String? validateConfirmation(
    String? value,
    String? originalValue, {
    String errorMessage = 'The values do not match',
  }) {
    if (value != originalValue) {
      return errorMessage;
    }
    return null;
  }

  /// Validates that the input has a minimum length.
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? errorMessage,
  }) {
    if (value == null || value.length < minLength) {
      return errorMessage ?? 'Must be at least $minLength characters long';
    }
    return null;
  }

  /// Validates that the input does not exceed a maximum length.
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? errorMessage,
  }) {
    if (value != null && value.length > maxLength) {
      return errorMessage ?? 'Cannot exceed $maxLength characters';
    }
    return null;
  }

  /// Validates the input as a numeric value.
  static String? validateNumber(
    String? value, {
    String errorMessage = 'Please enter a valid number',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (double.tryParse(value) == null) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input as an integer (whole number).
  static String? validateInteger(
    String? value, {
    String errorMessage = 'Please enter a whole number',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    if (int.tryParse(value) == null) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input as a basic phone number.
  static String? validatePhoneNumber(
    String? value, {
    String errorMessage = 'Please enter a valid phone number',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    final RegExp phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{7,}$');
    if (!phoneRegExp.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input as a valid URL.
  static String? validateUrl(
    String? value, {
    String errorMessage = 'Please enter a valid URL',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'URL cannot be empty';
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath || !uri.hasScheme) {
      return errorMessage;
    }
    return null;
  }

  /// Validates the input contains only letters and numbers.
  static String? validateAlphanumeric(
    String? value, {
    String errorMessage = 'Only letters and numbers are allowed',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    final RegExp alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegExp.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Validates a credit card number using the Luhn algorithm.
  static String? validateCreditCardNumber(
    String? value, {
    String errorMessage = 'Invalid credit card number',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Credit card number cannot be empty';
    }

    String cleanedValue = value.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    if (cleanedValue.length < 13) {
      return errorMessage;
    }

    int sum = 0;
    int length = cleanedValue.length;
    for (var i = 0; i < length; i++) {
      int digit = int.parse(cleanedValue[length - 1 - i]);
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return null;
    }

    return errorMessage;
  }
}
