import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

/// Abstract interface for cart persistence.
abstract class CartRepository {
  Future<List<CartItemModel>> getCart(String userId);
  Future<void> saveCart(String userId, List<CartItemModel> items);
  Future<void> clearCart(String userId);
}

// ── SharedPreferences Implementation ──────────────────────────────────────────
/// Persists cart data locally using SharedPreferences.
/// Cart is also synced to Firestore in production.
class SharedPrefsCartRepository implements CartRepository {
  static const String _prefix = 'cart_';

  String _key(String userId) => '$_prefix$userId';

  @override
  Future<List<CartItemModel>> getCart(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key(userId));
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCart(String userId, List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_key(userId), jsonStr);

      // TODO: Firebase — Sync to Firestore
      // final batch = FirebaseFirestore.instance.batch();
      // final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);
      // for (final item in items) {
      //   batch.set(cartRef.collection('items').doc(item.productId), item.toJson());
      // }
      // await batch.commit();
    } catch (_) {
      // Silent fail — cart still works in memory
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(userId));

      // TODO: Firebase — Clear Firestore cart
      // final docs = await FirebaseFirestore.instance.collection('cart')
      //     .doc(userId).collection('items').get();
      // for (final doc in docs.docs) {
      //   await doc.reference.delete();
      // }
    } catch (_) {}
  }
}
