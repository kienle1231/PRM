import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'package:uuid/uuid.dart';

/// Abstract interface for order operations.
abstract class OrderRepository {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}

// ── Shared Preferences Implementation ───────────────────────────────────────
class SharedPrefsOrderRepository implements OrderRepository {
  final String _prefKey = 'saved_orders_v1';
  bool _isInitialized = false;
  List<OrderModel> _orders = [];

  SharedPrefsOrderRepository();

  Future<void> _init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKey);
    
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _orders = jsonList.map((e) => OrderModel.fromJson(e)).toList();
      } catch (e) {
        _orders = _getInitialMockData();
      }
    } else {
      _orders = _getInitialMockData();
    }
    
    _isInitialized = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _orders.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKey, jsonEncode(jsonList));
  }

  List<OrderModel> _getInitialMockData() {
    final now = DateTime.now();
    return [
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
            stock: 10,
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
            stock: 10,
          ),
          CartItemModel(
            productId: 'acc002',
            name: 'Chuột Logitech G Pro X Superlight 2',
            price: 1890000,
            originalPrice: 2290000,
            imageUrl: 'https://placehold.co/400x300/1a1b2e/ffffff?text=Logitech+G+Pro+X',
            quantity: 1,
            stock: 10,
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
    ];
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 500));
    final newOrder = order.copyWith(
      id: 'TC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    await _persist();
    return newOrder;
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await _init();
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _init();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(
        status: OrderStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      await _persist();
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _init();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await _persist();
    }
  }
}
