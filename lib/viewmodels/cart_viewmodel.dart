import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';

/// Manages shopping cart state.
/// Handles add, remove, update quantity, total calculation, and persistence.
class CartViewModel extends ChangeNotifier {
  final SharedPrefsCartRepository _repo;
  String? _userId;

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _message; // Success/error feedback

  CartViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  String? get message => _message;

  /// Total number of items (sum of quantities)
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Cart item count (distinct products)
  int get distinctItemCount => _items.length;

  /// Subtotal (sum of all item subtotals, at sale price)
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Total savings across all items
  double get totalSavings =>
      _items.fold(0.0, (sum, item) => sum + item.lineSavings);

  /// Shipping fee: free over 500,000đ, otherwise 30,000đ
  double get shippingFee => subtotal >= 500000 ? 0.0 : 30000.0;

  /// Grand total = subtotal + shipping
  double get total => subtotal + shippingFee;

  // ── Initialize ────────────────────────────────────────────────────────────
  Future<void> initialize(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    _items = await _repo.getCart(userId);
    _isLoading = false;
    notifyListeners();
  }

  // ── Add to Cart ─────────────────────────────────────────────────────────────────────
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final idx = _items.indexWhere((i) => i.productId == product.id);
    if (idx >= 0) {
      // Đã có trong giỏ — kiểm tra tồn kho trước khi tăng
      final newQty = _items[idx].quantity + quantity;
      if (newQty > product.stock) {
        _message = 'Không thể thêm. Tồn kho chỉ còn ${product.stock}, đã có ${_items[idx].quantity} trong giỏ';
        notifyListeners();
        return;
      }
      _items[idx].quantity = newQty;
    } else {
      // Sản phẩm mới — kiểm tra số lượng yêu cầu với tồn kho
      if (quantity > product.stock) {
        _message = 'Số lượng vượt quá tồn kho (còn ${product.stock})';
        notifyListeners();
        return;
      }
      _items.add(CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price.toDouble(),
        originalPrice: product.originalPrice.toDouble(),
        imageUrl: product.primaryImage,
        quantity: quantity,
        stock: product.stock,
      ));
    }
    _message = '${product.name.length > 30 ? '${product.name.substring(0, 30)}...' : product.name} đã thêm vào giỏ';
    await _persist();
  }

  // ── Update Quantity ─────────────────────────────────────────────────────────────────
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      // Giới hạn không vượt quá tồn kho
      if (quantity > _items[idx].stock) {
        _items[idx].quantity = _items[idx].stock;
        _message = 'Số lượng tối đa là ${_items[idx].stock}';
      } else {
        _items[idx].quantity = quantity;
      }
      await _persist();
    }
  }

  Future<void> increment(String productId) async {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      // Kiểm tra tồn kho trước khi tăng
      if (_items[idx].quantity >= _items[idx].stock) {
        _message = 'Đã đạt số lượng tối đa trong kho (${_items[idx].stock})';
        notifyListeners();
        return;
      }
      _items[idx].quantity++;
      await _persist();
    }
  }

  Future<void> decrement(String productId) async {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
        await _persist();
      } else {
        await removeItem(productId);
      }
    }
  }

  // ── Remove Item ───────────────────────────────────────────────────────────
  Future<void> removeItem(String productId) async {
    _items.removeWhere((i) => i.productId == productId);
    await _persist();
  }

  // ── Clear Cart ────────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    _items = [];
    if (_userId != null) {
      await _repo.clearCart(_userId!);
    }
    notifyListeners();
  }

  // ── Check if in cart ──────────────────────────────────────────────────────
  bool isInCart(String productId) =>
      _items.any((i) => i.productId == productId);

  int quantityInCart(String productId) {
    try {
      return _items.firstWhere((i) => i.productId == productId).quantity;
    } catch (_) {
      return 0;
    }
  }

  // ── Persist ───────────────────────────────────────────────────────────────
  Future<void> _persist() async {
    notifyListeners();
    if (_userId != null) {
      await _repo.saveCart(_userId!, _items);
    }
  }

  // ── Clear Message ─────────────────────────────────────────────────────────
  void clearMessage() {
    _message = null;
    notifyListeners();
  }
}
