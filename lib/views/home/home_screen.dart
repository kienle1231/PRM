import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_row.dart';
import 'widgets/product_section.dart';

/// Home tab — main landing page with search, banners, categories, featured products.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load home data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<ProductViewModel>().loadHomeData(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(child: _buildAppBar(context, user?.name, isDark)),

              // Search Bar
              SliverToBoxAdapter(child: _buildSearchBar(isDark)),

              // Main Content
              SliverToBoxAdapter(
                child: Consumer<ProductViewModel>(
                  builder: (_, vm, __) {
                    if (vm.isLoading && vm.featuredProducts.isEmpty) {
                      return const _HomeShimmer();
                    }
                    return Column(
                      children: [
                        // Banner Carousel
                        const BannerCarousel(),
                        const SizedBox(height: 24),

                        // Categories
                        if (vm.categories.isNotEmpty) ...[
                          CategoryRow(categories: vm.categories),
                          const SizedBox(height: 24),
                        ],

                        // Featured Products
                        if (vm.featuredProducts.isNotEmpty) ...[
                          ProductSection(
                            title: AppStrings.featuredProducts,
                            products: vm.featuredProducts,
                            onSeeMore: () => Navigator.pushNamed(
                                context, AppRoutes.productList),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Hot Deals Banner
                        if (vm.hotDeals.isNotEmpty) _buildHotDealsBanner(context),

                        // Hot Deals Products
                        if (vm.hotDeals.isNotEmpty) ...[
                          ProductSection(
                            title: AppStrings.hotDeals,
                            products: vm.hotDeals,
                            onSeeMore: () => Navigator.pushNamed(
                                context, AppRoutes.productList),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? userName, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Logo & Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${userName?.split(' ').first ?? 'Bạn'} 👋',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Cart button
          Consumer<CartViewModel>(
            builder: (_, cartVM, __) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.cart),
                ),
                if (cartVM.totalItemCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cartVM.totalItemCount > 9
                              ? '9+'
                              : cartVM.totalItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.productList),
        child: AbsorbPointer(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 22),
                ),
                Text(
                  AppStrings.searchHint,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : AppColors.textHint,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotDealsBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 70,
      decoration: BoxDecoration(
        gradient: AppColors.hotDealGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FLASH SALE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    )),
                Text('Giảm đến 50% mỗi ngày!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Xem ngay',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for home screen.
class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
