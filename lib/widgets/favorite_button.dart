import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';

/// Reusable heart icon button to add/remove laptops to/from wishlist.
/// Supports both floating circular button (for catalog cards) and standard icon button (for App Bars).
class FavoriteButton extends StatelessWidget {
  final ProductModel product;
  final bool isFloating;
  final double iconSize;

  const FavoriteButton({
    super.key,
    required this.product,
    this.isFloating = true,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<WishlistProvider>(
      builder: (context, provider, _) {
        final isFav = provider.isFavorite(product.id);

        Widget buttonContent = AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey<bool>(isFav),
            size: iconSize,
            color: isFav ? AppColors.error : (isFloating ? AppColors.textSecondary : (isDark ? Colors.white70 : AppColors.textPrimary)),
          ),
        );

        if (isFloating) {
          return GestureDetector(
            onTap: () => _toggleFavorite(context, provider, isFav),
            child: Container(
              width: iconSize + 16,
              height: iconSize + 16,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(child: buttonContent),
            ),
          );
        } else {
          return IconButton(
            icon: buttonContent,
            iconSize: iconSize,
            tooltip: isFav ? 'Xóa khỏi danh sách yêu thích' : 'Thêm vào danh sách yêu thích',
            onPressed: () => _toggleFavorite(context, provider, isFav),
          );
        }
      },
    );
  }

  void _toggleFavorite(BuildContext context, WishlistProvider provider, bool isCurrentlyFav) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // Clear existing snackbars to avoid queuing delay
    messenger.hideCurrentSnackBar();

    if (isCurrentlyFav) {
      await provider.removeFromWishlist(product.id);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(messenger, provider.errorMessage!);
      } else {
        _showSuccessSnackbar(messenger, 'Đã xóa khỏi danh sách yêu thích 🤍', AppColors.textSecondary);
      }
    } else {
      await provider.addToWishlist(product);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(messenger, provider.errorMessage!);
      } else {
        _showSuccessSnackbar(messenger, 'Đã thêm vào danh sách yêu thích ❤️', AppColors.success);
      }
    }
  }

  void _showSuccessSnackbar(ScaffoldMessengerState messenger, String message, Color bgColor) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(ScaffoldMessengerState messenger, String errorMsg) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          errorMsg,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
