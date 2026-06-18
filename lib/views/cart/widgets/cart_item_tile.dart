import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/cart_item_model.dart';
import '../../../viewmodels/cart_viewmodel.dart';

/// Individual cart item tile with image, name, price, quantity controls, and remove.
class CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartVM = context.read<CartViewModel>();

    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xóa sản phẩm'),
            content: Text('Bạn có chắc muốn xóa "${item.name}" khỏi giỏ hàng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => cartVM.removeItem(item.productId),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(color: AppColors.borderDark, width: 0.5)
              : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primarySurface,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primarySurface,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.textHint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Prices
                  if (item.discountPercent > 0) ...[
                    Text(
                      AppFormatters.vnd(item.originalPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    AppFormatters.vnd(item.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stock info
                  Text(
                    'Kho: ${item.stock}',
                    style: TextStyle(
                      fontSize: 10,
                      color: item.quantity >= item.stock
                          ? AppColors.error
                          : (isDark ? Colors.white38 : AppColors.textHint),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Quantity controls
                  Row(
                    children: [
                      // Subtotal
                      Text(
                        'Tổng: ${AppFormatters.vnd(item.subtotal)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),

                      // Qty controls
                      Consumer<CartViewModel>(
                        builder: (_, vm, __) {
                          final atMax = item.quantity >= item.stock;
                          return Row(
                            children: [
                              _QtyBtn(
                                icon: Icons.remove,
                                onTap: () => vm.decrement(item.productId),
                              ),
                              Container(
                                width: 36,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.backgroundDark
                                      : AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              _QtyBtn(
                                icon: Icons.add,
                                onTap: atMax
                                    ? null
                                    : () => vm.increment(item.productId),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySurface : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}
