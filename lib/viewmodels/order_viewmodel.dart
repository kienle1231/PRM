import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

/// Manages order history state.
class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repo;

  List<OrderModel> _orders = [];
  List<OrderModel> _allOrders = []; // Dành cho Admin
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  OrderViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<OrderModel> get orders => _orders;
  List<OrderModel> get allOrders => _allOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Load Orders ───────────────────────────────────────────────────────────
  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repo.getOrders(userId);
    } catch (_) {
      _error = 'Không thể tải lịch sử đơn hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch All Orders (Admin) ──────────────────────────────────────────────
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allOrders = await _repo.getAllOrders();
    } catch (_) {
      _error = 'Không thể tải danh sách đơn hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load Order Detail ─────────────────────────────────────────────────────
  Future<void> loadOrderDetail(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedOrder = await _repo.getOrderById(orderId);
    } catch (_) {
      _error = 'Không thể tải chi tiết đơn hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cancel Order ──────────────────────────────────────────────────────────
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _repo.cancelOrder(orderId);
      // Update local list
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Update Order Status ───────────────────────────────────────────────────
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _repo.updateOrderStatus(orderId, newStatus);
      
      // Update in user list
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = _orders[idx].copyWith(status: newStatus);
      }
      
      // Update in admin list
      final adminIdx = _allOrders.indexWhere((o) => o.id == orderId);
      if (adminIdx >= 0) {
        _allOrders[adminIdx] = _allOrders[adminIdx].copyWith(status: newStatus);
      }
      
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Add a newly placed order to the top of the list.
  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
