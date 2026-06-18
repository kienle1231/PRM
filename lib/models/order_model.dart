import 'cart_item_model.dart';

/// Order status enum with display helpers.
enum OrderStatus {
  pending,
  paid,
  confirmed,
  shipping,
  completed,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.paid:
        return 'Đã thanh toán';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.paid:
        return '💳';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.shipping:
        return '🚚';
      case OrderStatus.completed:
        return '🎉';
      case OrderStatus.delivered:
        return '📦';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

/// Order model representing a placed order.
class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final String? note;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    this.note,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  /// Total quantity across all items.
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
        'status': status.name,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'shippingAddress': shippingAddress,
        'note': note,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        items: (json['items'] as List)
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        shippingFee: (json['shippingFee'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => OrderStatus.pending,
        ),
        customerName: json['customerName'] as String,
        customerPhone: json['customerPhone'] as String,
        shippingAddress: json['shippingAddress'] as String,
        note: json['note'] as String?,
        paymentMethod: json['paymentMethod'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? total,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? note,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      OrderModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        items: items ?? this.items,
        subtotal: subtotal ?? this.subtotal,
        shippingFee: shippingFee ?? this.shippingFee,
        total: total ?? this.total,
        status: status ?? this.status,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        shippingAddress: shippingAddress ?? this.shippingAddress,
        note: note ?? this.note,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
