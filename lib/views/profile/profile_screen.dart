import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../providers/wishlist_provider.dart';

/// User profile screen with account info, settings, and navigation links.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
            tooltip: AppStrings.editProfile,
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, OrderViewModel>(
        builder: (context, authVM, orderVM, __) {
          final user = authVM.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final wishlistCount =
              context.watch<WishlistProvider>().totalWishlistItems;
          final orderCount = orderVM.orders.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(
                  context,
                  user.name,
                  user.email,
                  orderCount,
                  wishlistCount,
                  isDark,
                ),

                const SizedBox(height: 8),

                // Menu Items
                _buildMenuSection(
                  title: 'Đơn hàng',
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.primary,
                      label: AppStrings.myOrders,
                      trailing: null,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.orderHistory),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.accent,
                      label: AppStrings.storeLocation,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.storeLocation),
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: AppColors.success,
                      label: AppStrings.support,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                    ),
                  ],
                  isDark: isDark,
                ),

                // ── Admin Panel Banner (chỉ hiện với admin) ─────────────
                if (user.isAdmin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminDashboard),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF16213E),
                              Color(0xFF0F3460)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppColors.secondary,
                                  size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Panel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Quản lý sản phẩm, đơn hàng & doanh thu',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white38, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),

                _buildMenuSection(
                  title: 'Tài khoản',
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      iconColor: AppColors.info,
                      label: AppStrings.editProfile,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.editProfile),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      label: AppStrings.notifications,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline_rounded,
                      iconColor: AppColors.error,
                      label: 'Danh sách yêu thích',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.wishlist),
                    ),
                  ],
                  isDark: isDark,
                ),

                _buildMenuSection(
                  title: 'Khác',
                  items: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textSecondary,
                      label: 'Về LAPTOPHUB',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      label: AppStrings.logout,
                      onTap: () => _showLogoutDialog(context, authVM),
                      textColor: AppColors.error,
                    ),
                  ],
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // App version
                Text(
                  'LAPTOPHUB v${AppStrings.appVersion}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 8),
                const Text(
                  '© 2026 LAPTOPHUB. All rights reserved.',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    int orderCount,
    int wishlistCount,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: orderCount.toString(), label: 'Đơn hàng'),
              Container(width: 1, height: 40, color: Colors.white30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.wishlist),
                child: _StatItem(
                    value: wishlistCount.toString(), label: 'Yêu thích'),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _StatItem(value: '0', label: 'Điểm tích lũy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDark
                ? Border.all(color: AppColors.borderDark, width: 0.5)
                : null,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.no),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authVM.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Về LAPTOPHUB'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LAPTOPHUB Mobile Store v1.0.0'),
            SizedBox(height: 8),
            Text('Ứng dụng mua sắm công nghệ chính hãng hàng đầu Việt Nam.'),
            SizedBox(height: 8),
            Text('FPT Đà Nẵng'),
            Text('Hotline: 1800 6789'),
            Text('Email: support@LAPTOPHUB.vn'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: textColor ?? AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
