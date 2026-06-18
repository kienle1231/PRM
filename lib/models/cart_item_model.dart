/// Cart item model with serialization.
class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final double originalPrice;
  final String imageUrl;
  int quantity;
  final int stock; // Tồn kho — dùng để kiểm tra giới hạn số lượng

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.quantity,
    required this.stock,
  });

  /// Subtotal for this line item at sale price.
  double get subtotal => price * quantity;

  /// Original total before discount.
  double get originalSubtotal => originalPrice * quantity;

  /// Savings for this line item.
  double get lineSavings => (originalPrice - price) * quantity;

  /// Discount percentage.
  int get discountPercent {
    if (originalPrice <= 0 || originalPrice <= price) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'stock': stock,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        quantity: json['quantity'] as int,
        stock: json['stock'] as int? ?? 999,
      );

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    int? quantity,
    int? stock,
  }) =>
      CartItemModel(
        productId: productId ?? this.productId,
        name: name ?? this.name,
        price: price ?? this.price,
        originalPrice: originalPrice ?? this.originalPrice,
        imageUrl: imageUrl ?? this.imageUrl,
        quantity: quantity ?? this.quantity,
        stock: stock ?? this.stock,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
