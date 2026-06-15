import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'widgets/cart_item_tile.dart';

/// Shopping cart screen.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<CartViewModel>(
          builder: (_, vm, __) => Text(
            '${AppStrings.cart} (${vm.totalItemCount})',
          ),
        ),
        actions: [
          Consumer<CartViewModel>(
            builder: (_, vm, __) => vm.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _showClearDialog(context, vm),
                    child: const Text('Xóa tất cả',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
          ),
        ],
      ),
      body: Consumer<CartViewModel>(
        builder: (_, cartVM, __) {
          if (cartVM.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (cartVM.isEmpty) {
            return _buildEmptyCart(context, isDark);
          }
          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartVM.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      CartItemTile(item: cartVM.items[i]),
                ),
              ),

              // Order Summary
              _buildOrderSummary(context, cartVM, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.shopping_cart_outlined,
                  size: 56, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.cartEmpty,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.cartEmptyDesc,
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.productList),
              child: const Text(AppStrings.shopNow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
      BuildContext context, CartViewModel cartVM, bool isDark) {
    final authVM = context.read<AuthViewModel>();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Savings notice
          if (cartVM.totalSavings > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Bạn tiết kiệm được ${AppFormatters.vnd(cartVM.totalSavings)}!',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Price rows
          _SummaryRow(
              label: AppStrings.subtotal,
              value: AppFormatters.vnd(cartVM.subtotal)),
          const SizedBox(height: 6),
          _SummaryRow(
            label: AppStrings.shipping,
            value: cartVM.shippingFee == 0
                ? AppStrings.freeShipping
                : AppFormatters.vnd(cartVM.shippingFee),
            valueColor: cartVM.shippingFee == 0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryRow(
            label: AppStrings.total,
            value: AppFormatters.vnd(cartVM.total),
            isBold: true,
            valueColor: AppColors.secondary,
          ),
          const SizedBox(height: 16),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: authVM.isAuthenticated
                  ? () => Navigator.pushNamed(context, AppRoutes.checkout)
                  : () => Navigator.pushNamed(context, AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.checkout,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.vnd(cartVM.total),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              vm.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? null : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
