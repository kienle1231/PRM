import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/product_model.dart';
import '../../products/widgets/product_card.dart';

/// Section with title, "see all" button, and horizontal or grid product list.
class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback? onSeeMore;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onSeeMore != null)
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text(AppStrings.viewAll,
                      style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Horizontal product scroll
        SizedBox(
          height: 268,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (_, i) => SizedBox(
              width: 170,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ProductCard(product: products[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
