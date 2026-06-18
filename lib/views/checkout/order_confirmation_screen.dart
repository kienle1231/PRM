import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';

/// Order confirmation screen shown after successful order placement.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order =
        ModalRoute.of(context)?.settings.arguments as OrderModel?;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(),

                // Success animation
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Đặt hàng thành công! 🎉',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cảm ơn bạn đã tin tưởng KienCare!\nChúng tôi sẽ liên hệ xác nhận trong thời gian sớm nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                if (order != null) ...[
                  const SizedBox(height: 32),
                  // Order info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _OrderInfoRow(
                          label: 'Mã đơn hàng',
                          value: AppFormatters.orderId(order.id),
                          valueBold: true,
                        ),
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: 'Ngày đặt',
                          value: AppFormatters.dateTime(order.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: 'Sản phẩm',
                          value: '${order.totalQuantity} sản phẩm',
                        ),
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: 'Tổng tiền',
                          value: AppFormatters.vnd(order.total),
                          valueColor: AppColors.secondary,
                          valueBold: true,
                        ),
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: 'Thanh toán',
                          value: order.paymentMethod,
                        ),
                        const SizedBox(height: 8),
                        _OrderInfoRow(
                          label: 'Trạng thái',
                          value: order.status.label,
                          valueColor: order.status == OrderStatus.paid
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.orderHistory,
                      (route) => route.isFirst,
                    ),
                    child: const Text('Theo dõi đơn hàng',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (_) => false,
                    ),
                    child: const Text('Tiếp tục mua sắm',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  final Color? valueColor;

  const _OrderInfoRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.primary,
          ),
        ),
      ],
    );
  }
}
