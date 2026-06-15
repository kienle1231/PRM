/// Product model with all display helpers.
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final double price;
  final double originalPrice;
  final List<String> images;
  final String description;
  final Map<String, String> specs;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isHotDeal;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.originalPrice,
    required this.images,
    required this.description,
    required this.specs,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    this.isFeatured = false,
    this.isHotDeal = false,
    required this.createdAt,
  });

  // ── Computed Properties ───────────────────────────────────────────────────
  String get primaryImage =>
      images.isNotEmpty ? images.first : '';

  bool get inStock => stock > 0;

  bool get hasDiscount => originalPrice > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  double get savingsAmount => originalPrice - price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'price': price,
        'originalPrice': originalPrice,
        'images': images,
        'description': description,
        'specs': specs,
        'stock': stock,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
        'isHotDeal': isHotDeal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num).toDouble(),
        images: List<String>.from(json['images'] as List),
        description: json['description'] as String,
        specs: Map<String, String>.from(json['specs'] as Map),
        stock: json['stock'] as int,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        isFeatured: json['isFeatured'] as bool? ?? false,
        isHotDeal: json['isHotDeal'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
