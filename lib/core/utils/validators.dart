/// Centralized form validators for KienCare app.
abstract class AppValidators {
  // ── Email ──────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }

  /// Returns a FormField validator that checks the value matches [passwordValue].
  static String? Function(String?) confirmPassword(String passwordValue) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }
      if (value != passwordValue) {
        return 'Mật khẩu xác nhận không khớp';
      }
      return null;
    };
  }

  // ── Full Name ──────────────────────────────────────────────────────────────
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  // ── Phone ──────────────────────────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^(0[0-9]{9}|84[0-9]{9})$').hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ (VD: 09xx xxx xxx)';
    }
    return null;
  }

  // ── Required ───────────────────────────────────────────────────────────────
  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}
