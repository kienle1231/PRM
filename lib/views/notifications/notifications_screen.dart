import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_model.dart';
import '../../viewmodels/notification_viewmodel.dart';

/// Notifications list screen.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (_, vm, __) => vm.hasUnread
                ? TextButton(
                    onPressed: vm.markAllAsRead,
                    child: const Text(AppStrings.markAllRead,
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (_, vm, __) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (vm.notifications.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NotifTile(
              notification: vm.notifications[i],
              onTap: () {
                vm.markAsRead(vm.notifications[i].id);
                _navigateFromNotification(context, vm.notifications[i]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(AppStrings.noNotifications,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Điều hướng dựa trên type và route của thông báo.
  static void _navigateFromNotification(
      BuildContext context, NotificationModel n) {
    switch (n.type) {
      case NotificationType.order:
        Navigator.pushNamed(context, AppRoutes.orderHistory);
        break;
      case NotificationType.promotion:
        if (n.routeParam != null && n.routeParam!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: n.routeParam,
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.productList);
        }
        break;
      case NotificationType.system:
        if (n.route == '/cart') {
          Navigator.pushNamed(context, AppRoutes.cart);
        }
        break;
      case NotificationType.news:
        // Tin tức: không điều hướng thêm, chỉ đánh dấu đã đọc
        break;
    }
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotifTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? AppColors.cardDark : Colors.white)
              : (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primarySurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : AppColors.primary.withValues(alpha: 0.3),
            width: isRead ? 0.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBg(notification.type, isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(notification.type.icon,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.relativeTime(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _iconBg(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.promotion:
        return isDark
            ? AppColors.secondary.withValues(alpha: 0.2)
            : const Color(0xFFFFF0F3);
      case NotificationType.order:
        return isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.primarySurface;
      case NotificationType.system:
        return isDark
            ? Colors.grey.withValues(alpha: 0.2)
            : Colors.grey.shade100;
      case NotificationType.news:
        return isDark
            ? AppColors.success.withValues(alpha: 0.2)
            : const Color(0xFFF0FFF4);
    }
  }
}
