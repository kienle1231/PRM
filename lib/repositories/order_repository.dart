import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// Abstract interface for order operations.
abstract class OrderRepository {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}

/// Persists orders locally using SQLite.
class SQLiteOrderRepository implements OrderRepository {
  static const String _databaseName = 'kiencare_orders.db';
  static const int _databaseVersion = 1;
  static const String _ordersTable = 'orders';
  static const String _itemsTable = 'order_items';

  static Database? _database;
  bool _isInitialized = false;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_ordersTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subtotal REAL NOT NULL,
        shipping_fee REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        shipping_address TEXT NOT NULL,
        note TEXT,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_itemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        original_price REAL NOT NULL,
        image_url TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        FOREIGN KEY(order_id) REFERENCES $_ordersTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_orders_user_id ON $_ordersTable(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_order_items_order_id ON $_itemsTable(order_id)',
    );
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    final db = await _db;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_ordersTable'),
        ) ??
        0;

    if (count == 0) {
      await db.transaction((txn) async {
        for (final order in _getInitialMockData()) {
          await _insertOrder(txn, order);
        }
      });
    }

    _isInitialized = true;
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 500));

    final newOrder = order.copyWith(
      id: 'TC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    final db = await _db;
    await db.transaction((txn) => _insertOrder(txn, newOrder));
    return newOrder;
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 300));

    final orders = await _getOrders(where: 'user_id = ?', whereArgs: [userId]);
    return orders;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    await _init();
    await Future.delayed(const Duration(milliseconds: 300));

    return _getOrders();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await _init();

    final orders = await _getOrders(where: 'id = ?', whereArgs: [orderId]);
    if (orders.isEmpty) return null;
    return orders.first;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _init();

    final db = await _db;
    await db.update(
      _ordersTable,
      {
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> _insertOrder(Transaction txn, OrderModel order) async {
    await txn.insert(
      _ordersTable,
      _orderToRow(order),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await txn.delete(
      _itemsTable,
      where: 'order_id = ?',
      whereArgs: [order.id],
    );

    for (final item in order.items) {
      await txn.insert(_itemsTable, _orderItemToRow(order.id, item));
    }
  }

  Future<List<OrderModel>> _getOrders({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;
    final orderRows = await db.query(
      _ordersTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    final result = <OrderModel>[];
    for (final row in orderRows) {
      final itemRows = await db.query(
        _itemsTable,
        where: 'order_id = ?',
        whereArgs: [row['id']],
        orderBy: 'id ASC',
      );
      result.add(_orderFromRows(row, itemRows));
    }

    return result;
  }

  Map<String, Object?> _orderToRow(OrderModel order) => {
        'id': order.id,
        'user_id': order.userId,
        'subtotal': order.subtotal,
        'shipping_fee': order.shippingFee,
        'total': order.total,
        'status': order.status.name,
        'customer_name': order.customerName,
        'customer_phone': order.customerPhone,
        'shipping_address': order.shippingAddress,
        'note': order.note,
        'payment_method': order.paymentMethod,
        'created_at': order.createdAt.toIso8601String(),
        'updated_at': order.updatedAt?.toIso8601String(),
      };

  Map<String, Object?> _orderItemToRow(String orderId, CartItemModel item) => {
        'order_id': orderId,
        'product_id': item.productId,
        'name': item.name,
        'price': item.price,
        'original_price': item.originalPrice,
        'image_url': item.imageUrl,
        'quantity': item.quantity,
        'stock': item.stock,
      };

  OrderModel _orderFromRows(
    Map<String, Object?> orderRow,
    List<Map<String, Object?>> itemRows,
  ) =>
      OrderModel(
        id: orderRow['id'] as String,
        userId: orderRow['user_id'] as String,
        items: itemRows.map(_cartItemFromRow).toList(),
        subtotal: (orderRow['subtotal'] as num).toDouble(),
        shippingFee: (orderRow['shipping_fee'] as num).toDouble(),
        total: (orderRow['total'] as num).toDouble(),
        status: OrderStatus.values.firstWhere(
          (status) => status.name == orderRow['status'],
          orElse: () => OrderStatus.pending,
        ),
        customerName: orderRow['customer_name'] as String,
        customerPhone: orderRow['customer_phone'] as String,
        shippingAddress: orderRow['shipping_address'] as String,
        note: orderRow['note'] as String?,
        paymentMethod: orderRow['payment_method'] as String,
        createdAt: DateTime.parse(orderRow['created_at'] as String),
        updatedAt: orderRow['updated_at'] != null
            ? DateTime.parse(orderRow['updated_at'] as String)
            : null,
      );

  CartItemModel _cartItemFromRow(Map<String, Object?> row) => CartItemModel(
        productId: row['product_id'] as String,
        name: row['name'] as String,
        price: (row['price'] as num).toDouble(),
        originalPrice: (row['original_price'] as num).toDouble(),
        imageUrl: row['image_url'] as String,
        quantity: row['quantity'] as int,
        stock: row['stock'] as int,
      );

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
            imageUrl:
                'https://placehold.co/400x300/1a1b2e/0052CC?text=ASUS+VivoBook+15',
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
            imageUrl:
                'https://placehold.co/400x300/1a1b2e/ffffff?text=Logitech+G915',
            quantity: 1,
            stock: 10,
          ),
          CartItemModel(
            productId: 'acc002',
            name: 'Chuột Logitech G Pro X Superlight 2',
            price: 1890000,
            originalPrice: 2290000,
            imageUrl:
                'https://placehold.co/400x300/1a1b2e/ffffff?text=Logitech+G+Pro+X',
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
}
