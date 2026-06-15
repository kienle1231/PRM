/// Category model for product categories.
class CategoryModel {
  final String id;
  final String name;
  final String icon;     // Emoji
  final String imageUrl;
  final int order;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.productCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'imageUrl': imageUrl,
        'order': order,
        'productCount': productCount,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        imageUrl: json['imageUrl'] as String,
        order: json['order'] as int,
        productCount: json['productCount'] as int,
      );
}
