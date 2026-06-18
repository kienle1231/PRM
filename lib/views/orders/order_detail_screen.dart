import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trạng thái đơn hàng
          _buildStatusCard(isDark),
          const SizedBox(height: 16),

          // Địa chỉ nhận hàng
          _buildAddressSection(isDark),
          const SizedBox(height: 16),

          // Danh sách sản phẩm
          _buildItemsSection(isDark),
          const SizedBox(height: 16),

          // Thông tin thanh toán
          _buildPaymentSummary(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mã đơn hàng', style: TextStyle(color: AppColors.textSecondary)),
              Text(AppFormatters.orderId(order.id), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ngày đặt', style: TextStyle(color: AppColors.textSecondary)),
              Text(AppFormatters.dateTime(order.createdAt), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(order.status.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                order.status.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Địa chỉ nhận hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(order.customerPhone),
          const SizedBox(height: 4),
          Text(order.shippingAddress, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildItemsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danh sách sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('x${item.quantity}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(AppFormatters.vnd(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          if (order.note != null && order.note!.isNotEmpty) ...[
            const Divider(),
            const Text('Lời nhắn:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(order.note!),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi tiết thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phương thức', style: TextStyle(color: AppColors.textSecondary)),
              Text(order.paymentMethod),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền hàng', style: TextStyle(color: AppColors.textSecondary)),
              Text(AppFormatters.vnd(order.subtotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phí vận chuyển', style: TextStyle(color: AppColors.textSecondary)),
              Text(AppFormatters.vnd(order.shippingFee)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                AppFormatters.vnd(order.total),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
