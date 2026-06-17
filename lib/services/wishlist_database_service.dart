import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/wishlist_model.dart';

/// Database service managing local storage for the product wishlist.
/// Implemented as a Singleton with a SharedPreferences fallback on the Web platform.
class WishlistDatabaseService {
  // Singleton instance
  static final WishlistDatabaseService _instance = WishlistDatabaseService._internal();

  factory WishlistDatabaseService() => _instance;

  WishlistDatabaseService._internal();

  static Database? _database;
  static const String _webPrefsKeyPrefix = 'kiencare_wishlist_user_';

  /// Get the active database instance, initializing it if necessary.
  /// Note: Throws UnsupportedError if called on the Web platform.
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on the Web. SharedPreferences fallback is used instead.');
    }
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database.
  Future<Database> initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'kiencare_wishlist.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      debugPrint('[WishlistDB] Error initializing database: $e');
      rethrow;
    }
  }

  /// Create SQLite table schema.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_id TEXT UNIQUE,
        product_name TEXT,
        product_image TEXT,
        price REAL,
        rating REAL,
        created_at TEXT
      )
    ''');
    debugPrint('[WishlistDB] Database table created successfully.');
  }

  // ── Web Fallback (SharedPreferences) Helpers ─────────────────────────────────

  Future<List<WishlistModel>> _getWebWishlist(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_webPrefsKeyPrefix$userId';
    final List<String>? jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];
    return jsonList.map((item) {
      try {
        final Map<String, dynamic> map = jsonDecode(item);
        return WishlistModel.fromMap(map);
      } catch (e) {
        debugPrint('[WishlistDB] Error decoding web item: $e');
        return null;
      }
    }).whereType<WishlistModel>().toList();
  }

  Future<void> _saveWebWishlist(int userId, List<WishlistModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_webPrefsKeyPrefix$userId';
    final jsonList = list.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(key, jsonList);
  }

  // ── Database Operations ──────────────────────────────────────────────────────

  /// Insert a product into the wishlist.
  Future<int> insertWishlist(WishlistModel wishlist) async {
    if (kIsWeb) {
      try {
        final userId = wishlist.userId ?? 1;
        final list = await _getWebWishlist(userId);
        // Prevent duplicates
        list.removeWhere((item) => item.productId == wishlist.productId);
        list.insert(0, wishlist);
        await _saveWebWishlist(userId, list);
        return 1;
      } catch (e) {
        debugPrint('[WishlistDB] Web error inserting: $e');
        rethrow;
      }
    }

    try {
      final db = await database;
      return await db.insert(
        'wishlist',
        wishlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error inserting: $e');
      rethrow;
    }
  }

  /// Delete a product from the wishlist by its product_id.
  Future<int> deleteWishlist(String productId) async {
    if (kIsWeb) {
      try {
        const userId = 1; // Default web user ID
        final list = await _getWebWishlist(userId);
        final initialLength = list.length;
        list.removeWhere((item) => item.productId == productId);
        if (list.length != initialLength) {
          await _saveWebWishlist(userId, list);
          return 1;
        }
        return 0;
      } catch (e) {
        debugPrint('[WishlistDB] Web error deleting: $e');
        rethrow;
      }
    }

    try {
      final db = await database;
      return await db.delete(
        'wishlist',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error deleting: $e');
      rethrow;
    }
  }

  /// Get all wishlist items for a specific user.
  Future<List<WishlistModel>> getWishlist(int userId) async {
    if (kIsWeb) {
      try {
        return await _getWebWishlist(userId);
      } catch (e) {
        debugPrint('[WishlistDB] Web error fetching: $e');
        rethrow;
      }
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'wishlist',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) => WishlistModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error fetching: $e');
      rethrow;
    }
  }

  /// Check if a product exists in the wishlist.
  Future<bool> checkFavorite(String productId) async {
    if (kIsWeb) {
      try {
        const userId = 1;
        final list = await _getWebWishlist(userId);
        return list.any((item) => item.productId == productId);
      } catch (e) {
        debugPrint('[WishlistDB] Web error checking favorite: $e');
        return false;
      }
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'wishlist',
        where: 'product_id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error checking favorite: $e');
      return false;
    }
  }

  /// Clear all wishlist items for a specific user.
  Future<int> clearWishlist(int userId) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = '$_webPrefsKeyPrefix$userId';
        await prefs.remove(key);
        return 1;
      } catch (e) {
        debugPrint('[WishlistDB] Web error clearing: $e');
        rethrow;
      }
    }

    try {
      final db = await database;
      return await db.delete(
        'wishlist',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error clearing: $e');
      rethrow;
    }
  }
}
