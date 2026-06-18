import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../viewmodels/order_viewmodel.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderViewModel>().fetchAllOrders(),
          ),
        ],
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.allOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null && vm.allOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(vm.error!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchAllOrders(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (vm.allOrders.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có đơn hàng nào trong hệ thống',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchAllOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.allOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) => _AdminOrderCard(order: vm.allOrders[index]),
            ),
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const _AdminOrderCard({required this.order});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.paid:
        return AppColors.accent;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.shipping:
        return AppColors.accent;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng: #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(order.status.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        order.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Customer Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.person_outline, text: order.customerName),
                const SizedBox(height: 4),
                _InfoRow(icon: Icons.phone_outlined, text: order.customerPhone),
                const SizedBox(height: 4),
                _InfoRow(icon: Icons.payment_outlined, text: order.paymentMethod),
              ],
            ),
          ),
          const Divider(height: 1),

          // Total row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalQuantity} sản phẩm',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Tổng: ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      TextSpan(
                        text: AppFormatters.vnd(order.total),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          if (_buildActionButtons(context) != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildActionButtons(context)!,
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildActionButtons(BuildContext context) {
    final vm = context.read<OrderViewModel>();

    // Nếu đơn hàng đang chờ xác nhận hoặc đã thanh toán
    if (order.status == OrderStatus.pending || order.status == OrderStatus.paid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => vm.updateOrderStatus(order.id, OrderStatus.confirmed),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Xác nhận đơn hàng', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }
    
    // Nếu đơn hàng đã xác nhận -> Shop giao cho ĐVVC
    if (order.status == OrderStatus.confirmed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => vm.updateOrderStatus(order.id, OrderStatus.shipping),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
          ),
          child: const Text('Giao cho ĐVVC', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }

    return null;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
