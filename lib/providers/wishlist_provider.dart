import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_database_service.dart';

/// State management provider for the wishlist feature.
/// Caches items in memory and updates the local SQLite database.
class WishlistProvider extends ChangeNotifier {
  final WishlistDatabaseService _dbService = WishlistDatabaseService();

  // In-memory cache of wishlist items
  List<WishlistModel> _wishlistItems = [];

  // Loading and error state flags
  bool _isLoading = false;
  String? _errorMessage;

  static const String _fallbackUserId = 'guest';
  String _activeUserId = _fallbackUserId;

  /// Cached list of wishlist items.
  List<WishlistModel> get wishlist => _wishlistItems;

  /// Total count of favorited products.
  int get totalWishlistItems => _wishlistItems.length;

  /// Returns true if the provider is currently fetching database content.
  bool get isLoading => _isLoading;

  /// Returns error message if any database operation fails.
  String? get errorMessage => _errorMessage;

  Future<void> setActiveUser(String? firebaseUid) async {
    final nextUserId = firebaseUid == null || firebaseUid.isEmpty
        ? _fallbackUserId
        : firebaseUid;
    if (nextUserId == _activeUserId && _wishlistItems.isNotEmpty) return;

    final legacyUserId = _legacyLocalUserId(firebaseUid).toString();
    await _dbService.migrateUserId(legacyUserId, nextUserId);
    _activeUserId = nextUserId;
    await loadWishlist();
  }

  int _legacyLocalUserId(String? firebaseUid) {
    if (firebaseUid == null || firebaseUid.isEmpty) return 1;

    var hash = 0x811C9DC5;
    for (final unit in firebaseUid.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  /// Load wishlist from SQLite database into memory cache.
  Future<void> loadWishlist({String? userId}) async {
    final effectiveUserId = userId ?? _activeUserId;
    _isLoading = true;
    _errorMessage = null;
    // Don't call notifyListeners() here if we want to avoid extra rebuilds,
    // but doing so once is safe to show loading indicators.
    notifyListeners();

    try {
      _wishlistItems = await _dbService.getWishlist(effectiveUserId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('[WishlistProvider] Error loading wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a product to the wishlist database and memory cache.
  Future<void> addToWishlist(ProductModel product, {String? userId}) async {
    final effectiveUserId = userId ?? _activeUserId;
    _errorMessage = null;

    // Check if already in wishlist in memory to avoid duplicate database writes
    if (_wishlistItems.any((item) => item.productId == product.id)) {
      return;
    }

    final newItem = WishlistModel.fromProduct(product, userId: effectiveUserId);

    // Optimistic UI Update: add to cache immediately for responsive feel
    _wishlistItems.insert(0, newItem);
    notifyListeners();

    try {
      await _dbService.insertWishlist(newItem);
    } catch (e) {
      // Rollback cache on database failure
      _wishlistItems.removeWhere((item) => item.productId == product.id);
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('[WishlistProvider] Error adding to wishlist: $e');
      notifyListeners();
    }
  }

  /// Remove a product from the wishlist database and memory cache.
  Future<void> removeFromWishlist(String productId, {String? userId}) async {
    final effectiveUserId = userId ?? _activeUserId;
    _errorMessage = null;

    final index =
        _wishlistItems.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    // Save removed item for possible rollback
    final removedItem = _wishlistItems[index];

    // Optimistic UI Update: remove from cache immediately
    _wishlistItems.removeAt(index);
    notifyListeners();

    try {
      await _dbService.deleteWishlist(productId, effectiveUserId);
    } catch (e) {
      // Rollback cache on database failure
      if (index <= _wishlistItems.length) {
        _wishlistItems.insert(index, removedItem);
      } else {
        _wishlistItems.add(removedItem);
      }
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('[WishlistProvider] Error removing from wishlist: $e');
      notifyListeners();
    }
  }

  /// Synchronous favorite check against in-memory cache.
  /// Extremely fast, safe to run directly in Widget build() methods without polling SQLite.
  bool isFavorite(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  /// Clear the entire wishlist database and memory cache.
  Future<void> clearWishlist({String? userId}) async {
    final effectiveUserId = userId ?? _activeUserId;
    _errorMessage = null;
    final originalItems = List<WishlistModel>.from(_wishlistItems);

    _wishlistItems.clear();
    notifyListeners();

    try {
      await _dbService.clearWishlist(effectiveUserId);
    } catch (e) {
      // Rollback cache on database failure
      _wishlistItems = originalItems;
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('[WishlistProvider] Error clearing wishlist: $e');
      notifyListeners();
    }
  }
}
