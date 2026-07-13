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
  static final WishlistDatabaseService _instance =
      WishlistDatabaseService._internal();

  factory WishlistDatabaseService() => _instance;

  WishlistDatabaseService._internal();

  static Database? _database;
  static const String _webPrefsKeyPrefix = 'kiencare_wishlist_user_';

  /// Get the active database instance, initializing it if necessary.
  /// Note: Throws UnsupportedError if called on the Web platform.
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
          'SQLite is not supported on the Web. SharedPreferences fallback is used instead.');
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
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('[WishlistDB] Error initializing database: $e');
      rethrow;
    }
  }

  /// Create SQLite table schema.
  Future<void> _onCreate(Database db, int version) async {
    await _createWishlistTable(db);
    debugPrint('[WishlistDB] Database table created successfully.');
  }

  Future<void> _createWishlistTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL CHECK(length(trim(user_id)) > 0),
        product_id TEXT NOT NULL CHECK(length(trim(product_id)) > 0),
        product_name TEXT NOT NULL,
        product_image TEXT NOT NULL,
        price REAL NOT NULL CHECK(price >= 0),
        rating REAL NOT NULL DEFAULT 0 CHECK(rating >= 0 AND rating <= 5),
        created_at TEXT NOT NULL,
        UNIQUE(user_id, product_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion >= 3) return;

    await db.execute('ALTER TABLE wishlist RENAME TO wishlist_old');
    await _createWishlistTable(db);
    await db.execute('''
      INSERT OR IGNORE INTO wishlist (
        user_id,
        product_id,
        product_name,
        product_image,
        price,
        rating,
        created_at
      )
      SELECT
        CAST(COALESCE(user_id, 1) AS TEXT),
        product_id,
        COALESCE(product_name, ''),
        COALESCE(product_image, ''),
        CASE WHEN price IS NULL OR price < 0 THEN 0 ELSE price END,
        CASE
          WHEN rating IS NULL OR rating < 0 THEN 0
          WHEN rating > 5 THEN 5
          ELSE rating
        END,
        COALESCE(created_at, CURRENT_TIMESTAMP)
      FROM wishlist_old
      WHERE product_id IS NOT NULL AND trim(product_id) <> ''
    ''');
    await db.execute('DROP TABLE wishlist_old');
  }

  // ── Web Fallback (SharedPreferences) Helpers ─────────────────────────────────

  Future<List<WishlistModel>> _getWebWishlist(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_webPrefsKeyPrefix$userId';
    final List<String>? jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];
    return jsonList
        .map((item) {
          try {
            final Map<String, dynamic> map = jsonDecode(item);
            return WishlistModel.fromMap(map);
          } catch (e) {
            debugPrint('[WishlistDB] Error decoding web item: $e');
            return null;
          }
        })
        .whereType<WishlistModel>()
        .toList();
  }

  Future<void> _saveWebWishlist(String userId, List<WishlistModel> list) async {
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
        final userId = wishlist.userId;
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
  Future<int> deleteWishlist(String productId, String userId) async {
    if (kIsWeb) {
      try {
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
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error deleting: $e');
      rethrow;
    }
  }

  /// Get all wishlist items for a specific user.
  Future<List<WishlistModel>> getWishlist(String userId) async {
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
  Future<bool> checkFavorite(String productId, String userId) async {
    if (kIsWeb) {
      try {
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
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('[WishlistDB] SQLite error checking favorite: $e');
      return false;
    }
  }

  /// Clear all wishlist items for a specific user.
  Future<int> clearWishlist(String userId) async {
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

  /// Moves data written by the legacy numeric user key to the Firebase uid.
  Future<void> migrateUserId(String oldUserId, String newUserId) async {
    if (oldUserId == newUserId) return;

    if (kIsWeb) {
      final oldItems = await _getWebWishlist(oldUserId);
      if (oldItems.isEmpty) return;

      final newItems = await _getWebWishlist(newUserId);
      final existingProductIds = newItems.map((item) => item.productId).toSet();
      for (final item in oldItems) {
        if (existingProductIds.add(item.productId)) {
          newItems.add(item.copyWith(userId: newUserId));
        }
      }
      await _saveWebWishlist(newUserId, newItems);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_webPrefsKeyPrefix$oldUserId');
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert(
        '''
        INSERT OR IGNORE INTO wishlist (
          user_id,
          product_id,
          product_name,
          product_image,
          price,
          rating,
          created_at
        )
        SELECT ?, product_id, product_name, product_image, price, rating, created_at
        FROM wishlist
        WHERE user_id = ?
        ''',
        [newUserId, oldUserId],
      );
      await txn.delete(
        'wishlist',
        where: 'user_id = ?',
        whereArgs: [oldUserId],
      );
    });
  }
}
