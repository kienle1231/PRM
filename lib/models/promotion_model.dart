import 'package:flutter/material.dart';

/// Loại chương trình khuyến mãi
enum PromotionType { flashSale, coupon, bundle, freeShip, event }

/// Model dữ liệu cho một chương trình khuyến mãi
class PromotionModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final PromotionType type;
  final int discountPercent; // 0 nếu không phải giảm % trực tiếp
  final String? discountLabel; // VD: "MIỄN PHÍ VẬN CHUYỂN", "Tặng quà"
  final Color primaryColor;
  final Color accentColor;
  final String emoji;
  final String tag; // VD: "FLASH SALE", "SỰ KIỆN"
  final DateTime endDate;
  final String route; // route điều hướng khi bấm
  final Object? routeArgs;
  final List<String> highlights; // Danh sách điểm nổi bật

  const PromotionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.discountPercent = 0,
    this.discountLabel,
    required this.primaryColor,
    required this.accentColor,
    required this.emoji,
    required this.tag,
    required this.endDate,
    required this.route,
    this.routeArgs,
    this.highlights = const [],
  });

  bool get isActive => endDate.isAfter(DateTime.now());

  /// Số ngày còn lại
  int get daysLeft => endDate.difference(DateTime.now()).inDays;

  /// Số giờ còn lại (nếu < 1 ngày)
  int get hoursLeft => endDate.difference(DateTime.now()).inHours;
}
