import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'home/home_screen.dart';
import 'products/product_list_screen.dart';
import 'cart/cart_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

/// Main app shell with bottom navigation bar.
/// Uses IndexedStack to keep tab state between switches.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = const [
    HomeScreen(),
    ProductListScreen(),
    CartScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Consumer2<CartViewModel, NotificationViewModel>(
      builder: (context, cartVM, notifVM, _) {
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            // Home
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            // Products
            const BottomNavigationBarItem(
              icon: Icon(Icons.laptop_outlined),
              activeIcon: Icon(Icons.laptop_rounded),
              label: AppStrings.navProducts,
            ),
            // Cart with badge
            BottomNavigationBarItem(
              icon: badges.Badge(
                showBadge: cartVM.totalItemCount > 0,
                badgeContent: Text(
                  cartVM.totalItemCount > 99
                      ? '99+'
                      : cartVM.totalItemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.secondary,
                  padding: EdgeInsets.all(4),
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: badges.Badge(
                showBadge: cartVM.totalItemCount > 0,
                badgeContent: Text(
                  cartVM.totalItemCount > 99
                      ? '99+'
                      : cartVM.totalItemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.secondary,
                  padding: EdgeInsets.all(4),
                ),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: AppStrings.navCart,
            ),
            // Notifications with badge
            BottomNavigationBarItem(
              icon: badges.Badge(
                showBadge: notifVM.hasUnread,
                badgeContent: Text(
                  notifVM.unreadCount > 9 ? '9+' : notifVM.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.secondary,
                  padding: EdgeInsets.all(4),
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: badges.Badge(
                showBadge: notifVM.hasUnread,
                badgeContent: Text(
                  notifVM.unreadCount > 9 ? '9+' : notifVM.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.secondary,
                  padding: EdgeInsets.all(4),
                ),
                child: const Icon(Icons.notifications_rounded),
              ),
              label: AppStrings.navNotifications,
            ),
            // Profile
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        );
      },
    );
  }
}
