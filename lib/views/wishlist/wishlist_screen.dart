import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/wishlist_model.dart';
import '../../providers/wishlist_provider.dart';

/// Màn hình hiển thị danh sách các mẫu laptop yêu thích đã lưu của người dùng.
/// Hỗ trợ tìm kiếm thời gian thực, sắp xếp và xử lý trạng thái lỗi/rỗng bằng tiếng Việt.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'price_asc', 'price_desc'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<WishlistProvider>(
          builder: (_, provider, __) {
            return Text('Yêu thích (${provider.totalWishlistItems})');
          },
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, _) {
          // 1. Xử lý trạng thái lỗi
          if (provider.errorMessage != null && provider.wishlist.isEmpty) {
            return _buildErrorState(provider.errorMessage!);
          }

          // 2. Trạng thái tải dữ liệu (chỉ hiện khi bộ nhớ đệm rỗng)
          if (provider.isLoading && provider.wishlist.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          // Lấy danh sách từ bộ nhớ đệm Provider
          var items = List<WishlistModel>.from(provider.wishlist);

          // Lọc theo tìm kiếm
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            items = items.where((item) {
              return item.productName.toLowerCase().contains(query);
            }).toList();
          }

          // Sắp xếp danh sách
          if (_sortBy == 'price_asc') {
            items.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortBy == 'price_desc') {
            items.sort((a, b) => b.price.compareTo(a.price));
          } else {
            // 'newest' (mới thêm gần đây)
            items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          // 3. Trạng thái rỗng (nếu db chưa có sản phẩm nào)
          if (provider.wishlist.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Thanh tìm kiếm và sắp xếp
              _buildSearchAndSortBar(isDark),

              // Số lượng kết quả lọc được
              if (_searchQuery.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tìm thấy ${items.length} sản phẩm phù hợp',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Danh sách sản phẩm yêu thích
              Expanded(
                child: items.isEmpty
                    ? _buildNoResultsState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _WishlistCard(
                            key: ValueKey(item.productId),
                            item: item,
                            isDark: isDark,
                            onRemove: () => _removeItem(context, provider, item.productId),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndSortBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Ô nhập tìm kiếm
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm laptop yêu thích...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Dropdown Sắp xếp
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary, size: 18),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _sortBy = newValue;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Mới thêm')),
                  DropdownMenuItem(value: 'price_asc', child: Text('Giá thấp → cao')),
                  DropdownMenuItem(value: 'price_desc', child: Text('Giá cao → thấp')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '❤️ Chưa có sản phẩm yêu thích',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bắt đầu khám phá và lưu lại những mẫu laptop bạn yêu thích.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Điều hướng trực tiếp sang tab danh sách sản phẩm trong Shell chính (index 1)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (route) => false,
                  arguments: 1, // Mở tab Laptop
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Khám phá Laptop'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có sản phẩm yêu thích nào khớp với "$_searchQuery"',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, WishlistProvider provider, String productId) async {
    final messenger = ScaffoldMessenger.of(context);
    await provider.removeFromWishlist(productId);
    
    if (provider.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Đã xóa khỏi danh sách yêu thích 🤍'),
          backgroundColor: AppColors.textSecondary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistModel item;
  final bool isDark;
  final VoidCallback onRemove;

  const _WishlistCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.borderDark, width: 0.5)
            : Border.all(color: AppColors.borderLight, width: 0.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ảnh sản phẩm
              SizedBox(
                width: 110,
                child: CachedNetworkImage(
                  imageUrl: item.productImage,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primarySurface,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primarySurface,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
                  ),
                ),
              ),

              // Thông tin & Hành động
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên laptop
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Đánh giá & Giá tiền
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            AppFormatters.rating(item.rating),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppFormatters.vnd(item.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),

                      // Các nút tác vụ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Nút Xóa
                          TextButton.icon(
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                            label: const Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Nút Xem chi tiết
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.productDetail,
                                arguments: item.productId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Xem chi tiết',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
