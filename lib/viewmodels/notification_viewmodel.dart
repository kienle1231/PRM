import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

/// Manages notification state and unread count badge.
class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repo;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _userId;

  NotificationViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Count of unread notifications — used for badge.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadNotifications(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repo.getNotifications(userId);
    } catch (_) {
      // Silent fail
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Mark as Read ──────────────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx >= 0 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
      await _repo.markAsRead(_userId!, notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _repo.markAllAsRead(_userId!);
  }

  // ── Add a new notification ────────────────────────────────────────────────
  Future<void> addNotification(NotificationModel notification) async {
    if (_userId == null) return;
    _notifications.insert(0, notification);
    notifyListeners();
    await _repo.addNotification(_userId!, notification);
  }

  // ── Convenience: thêm thông báo xác nhận đơn hàng ────────────────────────
  Future<void> addOrderNotification({
    required String orderId,
    required String orderDisplayId,
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      title: '✅ Đơn hàng $orderDisplayId đã được xác nhận',
      body:
          'Chúng tôi đã nhận được đơn hàng của bạn và đang xử lý. Cảm ơn bạn đã mua sắm tại LAPTOPHUB!',
      type: NotificationType.order,
      isRead: false,
      route: '/orders',
      routeParam: orderId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  // ── Convenience: thêm thông báo flash sale ────────────────────────────────
  Future<void> addFlashSaleNotification({
    required String productId,
    required String productName,
    required int discountPercent,
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      title: '🔥 Flash Sale - $productName giảm $discountPercent%',
      body:
          'Ưu đãi giới hạn! Nhanh tay sở hữu $productName với mức giảm $discountPercent% chỉ hôm nay.',
      type: NotificationType.promotion,
      isRead: false,
      route: '/product-detail',
      routeParam: productId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }
}
