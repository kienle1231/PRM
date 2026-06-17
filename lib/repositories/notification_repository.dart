import '../models/notification_model.dart';

/// Abstract interface for notification operations.
abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> addNotification(String userId, NotificationModel notification);
}

// ── Mock Implementation ────────────────────────────────────────────────────────
class MockNotificationRepository implements NotificationRepository {
  final Map<String, List<NotificationModel>> _notifications = {};

  MockNotificationRepository() {
    // Seed demo notifications for the demo user
    final now = DateTime.now();
    _notifications['user_demo'] = [
      NotificationModel(
        id: 'n001',
        title: '🎉 Khuyến mãi 10.10 đặc biệt!',
        body: 'Giảm đến 50% toàn bộ laptop và PC Gaming. Số lượng có hạn, mua ngay!',
        type: NotificationType.promotion,
        isRead: false,
        route: '/products',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: 'n002',
        title: '📦 Đơn hàng #TC20240002 đang giao',
        body: 'Đơn hàng của bạn đang được vận chuyển. Dự kiến nhận vào ngày mai.',
        type: NotificationType.order,
        isRead: false,
        route: '/orders',
        routeParam: 'TC20240002',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n003',
        title: '✅ Đơn hàng #TC20240001 đã giao thành công',
        body: 'Cảm ơn bạn đã mua hàng tại LAPTOPHUB. Hãy đánh giá sản phẩm nhé!',
        type: NotificationType.order,
        isRead: true,
        route: '/orders',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      NotificationModel(
        id: 'n004',
        title: '🔥 Flash Sale - RTX 4060 giảm 20%',
        body: 'Card màn hình ASUS ROG STRIX RTX 4060 giảm ngay 20%. Chỉ còn 5 sản phẩm!',
        type: NotificationType.promotion,
        isRead: true,
        route: '/product-detail',
        routeParam: 'cmp004',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: 'n005',
        title: '🛍️ Bạn có sản phẩm trong giỏ hàng',
        body: 'Bàn phím Logitech G915 đang chờ bạn! Đừng để lỡ cơ hội giảm giá.',
        type: NotificationType.system,
        isRead: true,
        route: '/cart',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'n006',
        title: '🏪 LAPTOPHUB khai trương cửa hàng mới',
        body: 'LAPTOPHUB vừa khai trương thêm chi nhánh tại Quận 7, TP.HCM. Ghé thăm nhận quà!',
        type: NotificationType.news,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _notifications[userId] ?? [];
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _notifications[userId];
    if (list == null) return;
    final idx = list.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(isRead: true);
    }
    // TODO: Firebase
    // await FirebaseFirestore.instance.collection('notifications')
    //     .doc(userId).collection('items').doc(notificationId)
    //     .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _notifications[userId];
    if (list == null) return;
    _notifications[userId] = list.map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<void> addNotification(String userId, NotificationModel notification) async {
    _notifications[userId] ??= [];
    _notifications[userId]!.insert(0, notification);
  }
}
