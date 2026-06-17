import 'product_model.dart';

/// Model representing a product added to the user's local wishlist.
class WishlistModel {
  final int? id;
  final int? userId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double rating;
  final String createdAt;

  const WishlistModel({
    this.id,
    this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.rating,
    required this.createdAt,
  });

  /// Convert a SQLite Database Map to a WishlistModel.
  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      productImage: map['product_image'] as String? ?? '',
      price: (map['price'] as num? ?? 0.0).toDouble(),
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  /// Convert a WishlistModel to a SQLite Database Map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'rating': rating,
      'created_at': createdAt,
    };
  }

  /// Create a WishlistModel from a ProductModel.
  factory WishlistModel.fromProduct(ProductModel product, {int? userId}) {
    return WishlistModel(
      userId: userId,
      productId: product.id,
      productName: product.name,
      productImage: product.primaryImage,
      price: product.price.toDouble(),
      rating: product.rating,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// Copy this model with optional updated values.
  WishlistModel copyWith({
    int? id,
    int? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? rating,
    String? createdAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistModel &&
          other.productId == productId &&
          other.userId == userId;

  @override
  int get hashCode => productId.hashCode ^ userId.hashCode;
}
