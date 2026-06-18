import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/checkout_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel>? singleItems;

  const CheckoutScreen({super.key, this.singleItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefill();
    });
  }

  void _prefill() {
    final authVM = context.read<AuthViewModel>();
    final checkoutVM = context.read<CheckoutViewModel>();
    checkoutVM.prefillFromUser(authVM);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  List<CartItemModel> get _checkoutItems {
    if (widget.singleItems != null) return widget.singleItems!;
    return context.read<CartViewModel>().items;
  }

  double get _subtotal {
    if (widget.singleItems != null) {
      return widget.singleItems!.fold(0, (sum, item) => sum + item.price * item.quantity);
    }
    return context.read<CartViewModel>().subtotal;
  }

  double get _shippingFee {
    if (widget.singleItems != null) {
      return _subtotal > 500000 ? 0 : 30000;
    }
    return context.read<CartViewModel>().shippingFee;
  }

  double get _total => _subtotal + _shippingFee;

  Future<void> _placeOrder() async {
    final checkoutVM = context.read<CheckoutViewModel>();

    if (checkoutVM.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ nhận hàng!')),
      );
      return;
    }

    final isOnlinePayment =
        checkoutVM.paymentMethod == 'Momo' || checkoutVM.paymentMethod == 'VNPay';

    if (isOnlinePayment) {
      Navigator.pushNamed(
        context,
        AppRoutes.payment,
        arguments: checkoutVM.paymentMethod,
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final cartVM = context.read<CartViewModel>();
    final orderVM = context.read<OrderViewModel>();

    final order = await checkoutVM.placeOrder(
      userId: authVM.currentUser?.id ?? 'guest',
      cartItems: _checkoutItems,
      subtotal: _subtotal,
      shippingFee: _shippingFee,
    );

    if (!mounted) return;

    if (order != null) {
      orderVM.addOrder(order);
      if (widget.singleItems == null) {
        await cartVM.clearCart();
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.orderConfirmation,
        arguments: order,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkoutVM.error ?? 'Đặt hàng thất bại'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkoutTitle),
        elevation: 1,
      ),
      body: Consumer2<CheckoutViewModel, CartViewModel>(
        builder: (context, checkoutVM, cartVM, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // 1. Địa chỉ nhận hàng
                    _buildAddressSection(context, checkoutVM.selectedAddress, isDark),
                    const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),

                    // 2. Sản phẩm
                    _buildProductsSection(context, isDark),
                    const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),

                    // 3. Lời nhắn
                    _buildNoteSection(checkoutVM, isDark),
                    const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),

                    // 4. Phương thức thanh toán
                    _buildPaymentMethodSection(checkoutVM, isDark),
                    const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),

                    // 5. Chi tiết thanh toán
                    _buildSummarySection(context, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Bar Đặt Hàng
              _buildBottomBar(context, checkoutVM, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, AddressModel? address, bool isDark) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(context, AppRoutes.addressSelection);
        if (result != null && result is AddressModel && mounted) {
          context.read<CheckoutViewModel>().setSelectedAddress(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: address == null
                  ? const Text(
                      'Vui lòng chọn địa chỉ nhận hàng',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Địa chỉ nhận hàng', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${address.name} | (+84) ${address.phone}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${address.address}\n${address.ward}, ${address.district}, ${address.province}',
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sản phẩm (${_checkoutItems.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          ..._checkoutItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('x${item.quantity}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(AppFormatters.vnd(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNoteSection(CheckoutViewModel checkoutVM, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text('Lời nhắn:', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _noteCtrl,
              onChanged: checkoutVM.setNote,
              decoration: const InputDecoration(
                hintText: 'Lưu ý cho người bán...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutViewModel vm, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _PaymentOption(
            label: AppStrings.cod,
            icon: Icons.money_rounded,
            selected: vm.paymentMethod == 'COD',
            onTap: () => vm.setPaymentMethod('COD'),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: AppStrings.momoPayment,
            icon: Icons.account_balance_wallet_rounded,
            selected: vm.paymentMethod == 'Momo',
            onTap: () => vm.setPaymentMethod('Momo'),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: AppStrings.vnpayPayment,
            icon: Icons.credit_card_rounded,
            selected: vm.paymentMethod == 'VNPay',
            onTap: () => vm.setPaymentMethod('VNPay'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi tiết thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền hàng', style: TextStyle(color: AppColors.textSecondary)),
              Text(AppFormatters.vnd(_subtotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phí vận chuyển', style: TextStyle(color: AppColors.textSecondary)),
              Text(_shippingFee == 0 ? 'Miễn phí' : AppFormatters.vnd(_shippingFee)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(AppFormatters.vnd(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CheckoutViewModel vm, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(fontSize: 12)),
                Text(
                  AppFormatters.vnd(_total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: vm.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Đặt Hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
          borderRadius: BorderRadius.circular(8),
          color: selected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
