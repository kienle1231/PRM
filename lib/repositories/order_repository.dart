import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'package:uuid/uuid.dart';

/// Abstract interface for order operations.
abstract class OrderRepository {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrders(String userId);
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> cancelOrder(String orderId);
}

// ── Mock Implementation ────────────────────────────────────────────────────────
class MockOrderRepository implements OrderRepository {
  final List<OrderModel> _orders = [];

  MockOrderRepository() {
    // Seed with sample order history
    final now = DateTime.now();
    _orders.addAll([
      OrderModel(
        id: 'TC20240001',
        userId: 'user_demo',
        items: [
          CartItemModel(
            productId: 'lap001',
            name: 'ASUS VivoBook 15 X515EA',
            price: 12500000,
            originalPrice: 14999000,
            imageUrl: 'https://placehold.co/400x300/1a1b2e/0052CC?text=ASUS+VivoBook+15',
            quantity: 1,
          ),
        ],
        subtotal: 12500000,
        shippingFee: 0,
        total: 12500000,
        status: OrderStatus.delivered,
        customerName: 'Nguyễn Văn An',
        customerPhone: '0912345678',
        shippingAddress: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        paymentMethod: 'COD',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      OrderModel(
        id: 'TC20240002',
        userId: 'user_demo',
        items: [
          CartItemModel(
            productId: 'acc001',
            name: 'Bàn phím Logitech G915 TKL Lightspeed',
            price: 3890000,
            originalPrice: 4690000,
            imageUrl: 'https://placehold.co/400x300/1a1b2e/ffffff?text=Logitech+G915',
            quantity: 1,
          ),
          CartItemModel(
            productId: 'acc002',
            name: 'Chuột Logitech G Pro X Superlight 2',
            price: 1890000,
            originalPrice: 2290000,
            imageUrl: 'https://placehold.co/400x300/1a1b2e/ffffff?text=Logitech+G+Pro+X',
            quantity: 1,
          ),
        ],
        subtotal: 5780000,
        shippingFee: 30000,
        total: 5810000,
        status: OrderStatus.shipping,
        customerName: 'Nguyễn Văn An',
        customerPhone: '0912345678',
        shippingAddress: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        paymentMethod: 'Bank Transfer',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newOrder = order.copyWith(
      id: 'TC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    // TODO: Firebase — Save to Firestore
    // await FirebaseFirestore.instance.collection('orders').doc(newOrder.id).set(newOrder.toJson());

    return newOrder;
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(
        status: OrderStatus.cancelled,
        updatedAt: DateTime.now(),
      );
    }

    // TODO: Firebase
    // await FirebaseFirestore.instance.collection('orders').doc(orderId)
    //     .update({'status': 'cancelled', 'updatedAt': DateTime.now().toIso8601String()});
  }
}
