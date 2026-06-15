import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import 'widgets/product_card.dart';

/// Product detail screen with image gallery, specs, add-to-cart.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  final int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productId =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        context.read<ProductViewModel>().loadProductDetail(productId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(ProductModel product, CartViewModel cartVM) {
    cartVM.addToCart(product, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã thêm $_quantity ${product.name.length > 20 ? '${product.name.substring(0, 20)}...' : product.name} vào giỏ'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProductViewModel>(
      builder: (_, vm, __) {
        final product = vm.selectedProduct;

        if (vm.isLoading || product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.productDetail)),
            body: const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // SliverAppBar with image gallery
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                backgroundColor:
                    isDark ? AppColors.surfaceDark : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Image
                      CachedNetworkImage(
                        imageUrl: product.images.isNotEmpty
                            ? product.images[_imageIndex]
                            : '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                        placeholder: (_, __) => Container(
                          color: AppColors.primarySurface,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primarySurface,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 48, color: AppColors.textHint),
                          ),
                        ),
                      ),

                      // Badges
                      if (product.hasDiscount)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  Consumer<CartViewModel>(
                    builder: (_, cartVM, __) => IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart_outlined),
                          if (cartVM.totalItemCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    cartVM.totalItemCount.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.cart),
                    ),
                  ),
                ],
              ),

              // Product Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Chip(
                        label: Text(product.categoryName),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(height: 8),

                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating & Stock
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating,
                            itemBuilder: (_, __) => const Icon(
                                Icons.star_rounded,
                                color: AppColors.accentYellow),
                            itemCount: 5,
                            itemSize: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppFormatters.rating(product.rating),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${AppFormatters.reviewCount(product.reviewCount)})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.inStock
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.inStock
                                  ? AppStrings.inStock
                                  : AppStrings.outOfStock,
                              style: TextStyle(
                                color: product.inStock
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      if (product.hasDiscount)
                        Text(
                          AppFormatters.vnd(product.originalPrice),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            AppFormatters.vnd(product.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.hotDealGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppFormatters.savings(
                                    product.originalPrice, product.price),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Quantity Selector
                      Row(
                        children: [
                          const Text('Số lượng:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          _QuantitySelector(
                            quantity: _quantity,
                            max: product.stock,
                            onDecrement: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            onIncrement: () {
                              if (_quantity < product.stock) {
                                setState(() => _quantity++);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tabs: Description | Specs
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        tabs: const [
                          Tab(text: AppStrings.description),
                          Tab(text: AppStrings.specifications),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 200,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Description tab
                            SingleChildScrollView(
                              child: Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            // Specs tab
                            _SpecsTable(specs: product.specs),
                          ],
                        ),
                      ),

                      // Related Products
                      if (vm.relatedProducts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.relatedProducts,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: vm.relatedProducts.length,
                            itemBuilder: (_, i) => SizedBox(
                              width: 160,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 12),
                                child: ProductCard(
                                    product: vm.relatedProducts[i]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120), // Space for bottom bar
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom action bar
          bottomNavigationBar: Consumer<CartViewModel>(
            builder: (_, cartVM, __) => Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Chat / wishlist icon
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.chat),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(52, 52),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Add to Cart
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: product.inStock
                          ? () => _addToCart(product, cartVM)
                          : null,
                      icon: const Icon(Icons.add_shopping_cart_rounded,
                          size: 20),
                      label: Text(
                        product.inStock
                            ? AppStrings.addToCart
                            : AppStrings.outOfStock,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.quantity,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? onDecrement : null),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        _QtyButton(
            icon: Icons.add,
            onTap: quantity < max ? onIncrement : null),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primarySurface : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, String> specs;

  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) {
      return const Center(
        child: Text('Chưa có thông số kỹ thuật',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: specs.entries.map((e) => _SpecRow(key: ValueKey(e.key), label: e.key, value: e.value)).toList(),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
