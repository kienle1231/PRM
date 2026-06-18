import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/checkout_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Giả lập thời gian xử lý giao dịch mạng 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    final authVM = context.read<AuthViewModel>();
    final cartVM = context.read<CartViewModel>();
    final checkoutVM = context.read<CheckoutViewModel>();
    final orderVM = context.read<OrderViewModel>();

    final order = await checkoutVM.placeOrder(
      userId: authVM.currentUser?.id ?? 'guest',
      cartItems: cartVM.items,
      subtotal: cartVM.subtotal,
      shippingFee: cartVM.shippingFee,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (order != null) {
      orderVM.addOrder(order);
      await cartVM.clearCart();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderConfirmation,
        (route) => route.settings.name == AppRoutes.main, // Xóa hết stack trừ Main (Home)
        arguments: order,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkoutVM.error ?? 'Đặt hàng thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _cancelPayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy thanh toán'),
        content: const Text('Bạn có chắc muốn hủy thanh toán và quay về trang chủ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final method = ModalRoute.of(context)?.settings.arguments as String?;
    final cartVM = context.watch<CartViewModel>();
    
    final isMomo = method == 'Momo';
    final methodName = isMomo ? 'MoMo' : 'VNPay';
    final methodColor = isMomo ? const Color(0xFFAE2070) : const Color(0xFF005BAA);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán $methodName'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelPayment,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Quét mã QR để thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Sử dụng ứng dụng $methodName hoặc ứng dụng Camera hỗ trợ QR code để quét mã.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              // Giả lập QR Code Mock
              Container(
                width: 240,
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fake QR Matrix
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MockPayment$methodName${cartVM.total}',
                      fit: BoxFit.cover,
                    ),
                    // Center Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: methodColor, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          isMomo ? Icons.account_balance_wallet : Icons.credit_card,
                          color: methodColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Total amount
              const Text(
                'Tổng tiền cần thanh toán',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.vnd(cartVM.total),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: methodColor,
                ),
              ),
              const SizedBox(height: 48),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: methodColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Tôi đã thanh toán',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _cancelPayment,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hủy hoặc thoát ra', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
