import 'package:flutter/material.dart';

/// Extension methods used across KienCare Mobile Store.

// ── BuildContext Extensions ───────────────────────────────────────────────────
extension ContextExtensions on BuildContext {
  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Is dark mode active?
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Current color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Show a SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Push a named route
  Future<T?> push<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamed<T>(this, routeName, arguments: arguments);

  /// Push a named route and remove current
  Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) =>
      Navigator.pushReplacementNamed<T, void>(this, routeName,
          arguments: arguments);

  /// Push and clear all stack
  Future<T?> pushAndClearStack<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamedAndRemoveUntil<T>(
          this, routeName, (_) => false, arguments: arguments);

  /// Pop current route
  void pop<T>([T? result]) => Navigator.pop(this, result);
}

// ── String Extensions ─────────────────────────────────────────────────────────
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis
  String truncate(int max) => length > max ? '${substring(0, max)}...' : this;

  /// Is valid email?
  bool get isValidEmail {
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  /// Is valid Vietnamese phone?
  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'[\s\-\+]'), '');
    final regex = RegExp(
        r'^(0|\+84)(3[2-9]|5[6-9]|7[06-9]|8[0-9]|9[0-9])[0-9]{7}$');
    return regex.hasMatch(digits);
  }
}

// ── Nullable String Extensions ────────────────────────────────────────────────
extension NullableStringExtensions on String? {
  /// Null-safe isEmpty check
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Null-safe non-empty check
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

// ── Double Extensions ─────────────────────────────────────────────────────────
extension DoubleExtensions on double {
  /// Clamp to non-negative
  double get nonNegative => clamp(0, double.infinity).toDouble();
}

// ── DateTime Extensions ───────────────────────────────────────────────────────
extension DateTimeExtensions on DateTime {
  /// Is today?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Is yesterday?
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

// ── Color Extensions ──────────────────────────────────────────────────────────
extension ColorExtensions on Color {
  /// Darken a color by [amount] (0.0 - 1.0)
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Lighten a color by [amount] (0.0 - 1.0)
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ── Widget Extensions ─────────────────────────────────────────────────────────
extension WidgetExtensions on Widget {
  /// Add padding to widget
  Widget padded([EdgeInsets padding = const EdgeInsets.all(16)]) =>
      Padding(padding: padding, child: this);

  /// Center widget
  Widget get centered => Center(child: this);

  /// Expand widget
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);
}
