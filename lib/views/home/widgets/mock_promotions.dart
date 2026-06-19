import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../models/promotion_model.dart';

/// Mock data cho các chương trình khuyến mãi hiện tại
class MockPromotions {
  static List<PromotionModel> get active {
    final now = DateTime.now();
    return [
      // 1. Flash Sale hàng ngày
      PromotionModel(
        id: 'promo_flash_01',
        title: 'Flash Sale Hằng Ngày',
        subtitle: 'Giảm đến 50% sản phẩm chọn lọc',
        description: 'Chương trình Flash Sale diễn ra mỗi ngày từ 12:00 - 14:00 và 20:00 - 22:00.',
        type: PromotionType.flashSale,
        discountPercent: 50,
        primaryColor: const Color(0xFFD4291F),
        accentColor: const Color(0xFFFF6B6B),
        emoji: '🔥',
        tag: 'FLASH SALE',
        endDate: DateTime(now.year, now.month, now.day, 22, 0),
        route: AppRoutes.productList,
        highlights: ['Laptop Gaming', 'PC Workstation', 'Màn hình 4K'],
      ),
      // 2. Sale 10.10 / Lễ hội mua sắm
      PromotionModel(
        id: 'promo_1010',
        title: 'Siêu Sale Mùa Hè',
        subtitle: 'Hàng ngàn sản phẩm giảm giá sốc',
        description: 'Chương trình khuyến mãi lớn nhất năm — giảm giá toàn bộ danh mục laptop, PC và phụ kiện.',
        type: PromotionType.event,
        discountPercent: 40,
        primaryColor: const Color(0xFF0A5E9A),
        accentColor: const Color(0xFF38B2FF),
        emoji: '🎉',
        tag: 'SỰ KIỆN',
        endDate: now.add(const Duration(days: 7)),
        route: AppRoutes.productList,
        highlights: ['MacBook Series', 'ASUS ROG', 'Dell XPS'],
      ),
      // 3. Miễn phí vận chuyển
      PromotionModel(
        id: 'promo_freeship',
        title: 'Miễn Phí Vận Chuyển',
        subtitle: 'Đơn hàng từ 500K — giao tận nơi miễn phí',
        description: 'Áp dụng cho tất cả đơn hàng từ 500.000đ trở lên trong toàn quốc.',
        type: PromotionType.freeShip,
        discountPercent: 0,
        discountLabel: 'MIỄN PHÍ SHIP',
        primaryColor: const Color(0xFF1A7A4A),
        accentColor: const Color(0xFF34C759),
        emoji: '🚚',
        tag: 'VẬN CHUYỂN',
        endDate: now.add(const Duration(days: 30)),
        route: AppRoutes.productList,
        highlights: ['Đơn từ 500K', 'Toàn quốc', 'Giao trong ngày'],
      ),
      // 4. Mua kèm quà tặng
      PromotionModel(
        id: 'promo_bundle_01',
        title: 'Mua Laptop Tặng Phụ Kiện',
        subtitle: 'Tặng chuột + túi chống sốc khi mua laptop',
        description: 'Mua bất kỳ laptop từ 15 triệu — tặng kèm chuột không dây và túi chống sốc cao cấp.',
        type: PromotionType.bundle,
        discountPercent: 0,
        discountLabel: 'TẶNG QUÀ',
        primaryColor: const Color(0xFF6A0DAD),
        accentColor: const Color(0xFFBF5FFF),
        emoji: '🎁',
        tag: 'TẶNG KÈM',
        endDate: now.add(const Duration(days: 14)),
        route: AppRoutes.productList,
        highlights: ['Chuột không dây', 'Túi chống sốc', 'Laptop ≥ 15tr'],
      ),
      // 5. Coupon sinh viên
      PromotionModel(
        id: 'promo_student',
        title: 'Ưu Đãi Sinh Viên',
        subtitle: 'Giảm thêm 8% cho học sinh, sinh viên',
        description: 'Xuất trình thẻ sinh viên hoặc email trường để nhận mã giảm giá độc quyền 8%.',
        type: PromotionType.coupon,
        discountPercent: 8,
        primaryColor: const Color(0xFF0052CC),
        accentColor: const Color(0xFF4C9AFF),
        emoji: '🎓',
        tag: 'SINH VIÊN',
        endDate: now.add(const Duration(days: 60)),
        route: AppRoutes.productList,
        highlights: ['Thẻ SV hợp lệ', 'Laptop văn phòng', 'Không giới hạn lần'],
      ),
    ];
  }
}
