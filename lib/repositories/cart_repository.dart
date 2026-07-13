import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/cart_item_model.dart';

/// Abstract interface for cart persistence.
abstract class CartRepository {
  Future<List<CartItemModel>> getCart(String userId);
  Future<void> saveCart(String userId, List<CartItemModel> items);
  Future<void> clearCart(String userId);
}

/// Persists cart data locally using SQLite.
class SQLiteCartRepository implements CartRepository {
  static const String _databaseName = 'kiencare_cart.db';
  static const int _databaseVersion = 2;
  static const String _tableName = 'cart_items';

  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) => _createTable(db),
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _createTable(DatabaseExecutor db) => db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL CHECK(length(trim(user_id)) > 0),
          product_id TEXT NOT NULL CHECK(length(trim(product_id)) > 0),
          name TEXT NOT NULL,
          price REAL NOT NULL CHECK(price >= 0),
          original_price REAL NOT NULL CHECK(original_price >= 0),
          image_url TEXT NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
          stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0),
          sort_order INTEGER NOT NULL DEFAULT 0 CHECK(sort_order >= 0),
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(user_id, product_id)
        )
      ''');

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion >= 2) return;

    await db.execute('ALTER TABLE $_tableName RENAME TO ${_tableName}_old');
    await _createTable(db);
    await db.execute('''
      INSERT INTO $_tableName (
        id, user_id, product_id, name, price, original_price, image_url,
        quantity, stock, sort_order, created_at, updated_at
      )
      SELECT
        id, user_id, product_id, name,
        CASE WHEN price < 0 THEN 0 ELSE price END,
        CASE WHEN original_price < 0 THEN 0 ELSE original_price END,
        image_url,
        CASE WHEN quantity <= 0 THEN 1 ELSE quantity END,
        CASE WHEN stock < 0 THEN 0 ELSE stock END,
        CASE WHEN sort_order < 0 THEN 0 ELSE sort_order END,
        created_at, updated_at
      FROM ${_tableName}_old
      WHERE trim(user_id) <> '' AND trim(product_id) <> ''
    ''');
    await db.execute('DROP TABLE ${_tableName}_old');
  }

  @override
  Future<List<CartItemModel>> getCart(String userId) async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'sort_order ASC, id ASC',
    );

    return rows.map(_cartItemFromRow).toList();
  }

  @override
  Future<void> saveCart(String userId, List<CartItemModel> items) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        await txn.insert(
          _tableName,
          _cartItemToRow(userId, item, now, index),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> clearCart(String userId) async {
    final db = await _db;
    await db.delete(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Map<String, Object?> _cartItemToRow(
    String userId,
    CartItemModel item,
    String timestamp,
    int sortOrder,
  ) =>
      {
        'user_id': userId,
        'product_id': item.productId,
        'name': item.name,
        'price': item.price,
        'original_price': item.originalPrice,
        'image_url': item.imageUrl,
        'quantity': item.quantity,
        'stock': item.stock,
        'sort_order': sortOrder,
        'created_at': timestamp,
        'updated_at': timestamp,
      };

  CartItemModel _cartItemFromRow(Map<String, Object?> row) => CartItemModel(
        productId: row['product_id'] as String,
        name: row['name'] as String,
        price: (row['price'] as num).toDouble(),
        originalPrice: (row['original_price'] as num).toDouble(),
        imageUrl: row['image_url'] as String,
        quantity: row['quantity'] as int,
        stock: row['stock'] as int,
      );
}
