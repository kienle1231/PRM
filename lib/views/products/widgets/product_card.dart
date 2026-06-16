import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product_model.dart';
import '../../../viewmodels/cart_viewmodel.dart';

/// Product card for grid and list displays.
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: isDark
              ? Border.all(color: AppColors.borderDark, width: 0.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _ProductImage(product: product),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Category
                    Text(
                      product.categoryName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Compact specs
                    _CompactSpecs(product: product),
                    const SizedBox(height: 4),

                    // Original Price (strikethrough)
                    if (product.hasDiscount)
                      Text(
                        AppFormatters.vnd(product.originalPrice),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    // Sale Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            AppFormatters.vnd(product.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        // Add to cart button
                        _AddToCartButton(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final ProductModel product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: CachedNetworkImage(
            imageUrl: product.primaryImage,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 120,
              color: AppColors.primarySurface,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.primary,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 120,
              color: AppColors.primarySurface,
              child: const Center(
                child:
                    Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
              ),
            ),
          ),
        ),

        // Discount badge
        if (product.hasDiscount)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${product.discountPercent}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        // Hot deal badge
        if (product.isHotDeal)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppColors.hotDealGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '🔥 HOT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final ProductModel product;

  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (_, cartVM, __) {
        final inCart = cartVM.isInCart(product.id);
        return GestureDetector(
          onTap: product.inStock
              ? () {
                  cartVM.addToCart(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã thêm vào giỏ hàng ✓'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: product.inStock
                  ? (inCart ? AppColors.success : AppColors.primary)
                  : AppColors.textHint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}

/// Compact specs display for product card: CPU/RAM/Storage and GPU/Display.
class _CompactSpecs extends StatelessWidget {
  final ProductModel product;

  const _CompactSpecs({required this.product});

  String _abbrevCpu(String cpu) => cpu
      .replaceAll('Intel Core ', '')
      .replaceAll('AMD Ryzen ', 'R')
      .replaceAll('Apple ', '')
      .trim();

  String _abbrevGpu(String gpu) => gpu
      .replaceAll('NVIDIA GeForce ', '')
      .replaceAll('NVIDIA ', '')
      .replaceAll('AMD Radeon ', '')
      .replaceAll('Intel Iris Xe', 'Iris Xe')
      .replaceAll('Intel UHD', 'UHD')
      .trim();

  @override
  Widget build(BuildContext context) {
    final cpu = _abbrevCpu(product.cpu);
    final ram = '${product.ramGB}GB';
    final storage =
        '${product.storage.capacityGB}GB ${product.storage.type}';
    final gpu = _abbrevGpu(product.gpu);
    final display = '${product.display.sizeInch}"';

    const style = TextStyle(
      fontSize: 9,
      color: AppColors.textHint,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$cpu • $ram • $storage',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$gpu • $display',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
