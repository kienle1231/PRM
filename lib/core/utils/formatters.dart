import 'package:intl/intl.dart';

/// Centralized formatters for KienCare data presentation.
abstract class AppFormatters {
  // ── Currency ──────────────────────────────────────────────────────────────
  static final _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Format price as Vietnamese Dong: ₫12,500,000
  static String vnd(double price) => _vndFormat.format(price);

  /// Format savings: "Tiết kiệm ₫2,499,000"
  static String savings(double original, double sale) {
    final saved = original - sale;
    return 'Tiết kiệm ${vnd(saved)}';
  }

  // ── Rating ────────────────────────────────────────────────────────────────
  /// Format rating to 1 decimal: "4.5"
  static String rating(double r) => r.toStringAsFixed(1);

  /// Format review count: "1.2k đánh giá"
  static String reviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k đánh giá';
    }
    return '$count đánh giá';
  }

  // ── Order ─────────────────────────────────────────────────────────────────
  /// Format order ID with # prefix: "#TC20240001"
  static String orderId(String id) => '#$id';

  // ── Date / Time ───────────────────────────────────────────────────────────
  static final _dtFormat = DateFormat('dd/MM/yyyy HH:mm', 'vi');
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'vi');

  /// Format datetime: "14/06/2024 10:30"
  static String dateTime(DateTime dt) => _dtFormat.format(dt);

  /// Format date only: "14/06/2024"
  static String date(DateTime dt) => _dateFormat.format(dt);

  /// Format relative time: "2 giờ trước", "vừa xong"
  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return date(dt);
  }
}
