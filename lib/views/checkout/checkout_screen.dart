import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/checkout_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';

/// Multi-step checkout screen: Info → Shipping → Payment → Summary.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _infoFormKey = GlobalKey<FormState>();
  final _shippingFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    final vm = context.read<CheckoutViewModel>();
    vm.prefillFromUser(
      name: user.name,
      phone: user.phone,
      address: user.address,
      province: user.province,
      district: user.district,
      ward: user.ward,
    );
    _nameCtrl.text = user.name;
    _phoneCtrl.text = user.phone;
    _addressCtrl.text = user.address ?? '';
    _provinceCtrl.text = user.province ?? '';
    _districtCtrl.text = user.district ?? '';
    _wardCtrl.text = user.ward ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _wardCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool _validateCurrentStep(int step) {
    if (step == 0) return _infoFormKey.currentState?.validate() ?? false;
    if (step == 1) return _shippingFormKey.currentState?.validate() ?? false;
    return true;
  }

  Future<void> _placeOrder() async {
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

    if (order != null) {
      orderVM.addOrder(order);
      await cartVM.clearCart();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<CheckoutViewModel, CartViewModel>(
      builder: (_, checkoutVM, cartVM, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.checkoutTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                if (checkoutVM.currentStep > 0) {
                  checkoutVM.prevStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Column(
            children: [
              // Step indicator
              _StepIndicator(currentStep: checkoutVM.currentStep),

              // Step content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(checkoutVM, cartVM, isDark),
                  ),
                ),
              ),

              // Bottom navigation
              _buildBottomNav(context, checkoutVM, cartVM),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(
      CheckoutViewModel vm, CartViewModel cartVM, bool isDark) {
    switch (vm.currentStep) {
      case 0:
        return _buildInfoStep(isDark);
      case 1:
        return _buildShippingStep(vm, isDark);
      case 2:
        return _buildSummaryStep(vm, cartVM, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoStep(bool isDark) {
    return Form(
      key: _infoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: AppStrings.customerInfo),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            validator: AppValidators.fullName,
            textInputAction: TextInputAction.next,
            onChanged: context.read<CheckoutViewModel>().setCustomerName,
            decoration: const InputDecoration(
              labelText: AppStrings.fullName,
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            validator: AppValidators.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: context.read<CheckoutViewModel>().setCustomerPhone,
            decoration: const InputDecoration(
              labelText: AppStrings.phone,
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingStep(CheckoutViewModel vm, bool isDark) {
    return Form(
      key: _shippingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: AppStrings.shippingAddress),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressCtrl,
            validator: (v) => AppValidators.required(v, fieldName: 'Địa chỉ'),
            textInputAction: TextInputAction.next,
            onChanged: vm.setAddress,
            decoration: const InputDecoration(
              labelText: 'Số nhà, tên đường',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _wardCtrl,
            textInputAction: TextInputAction.next,
            onChanged: vm.setWard,
            decoration: const InputDecoration(
              labelText: 'Phường / Xã',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _districtCtrl,
            textInputAction: TextInputAction.next,
            onChanged: vm.setDistrict,
            decoration: const InputDecoration(
              labelText: 'Quận / Huyện',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _provinceCtrl,
            validator: (v) => AppValidators.required(v, fieldName: 'Tỉnh/Thành phố'),
            textInputAction: TextInputAction.next,
            onChanged: vm.setProvince,
            decoration: const InputDecoration(
              labelText: 'Tỉnh / Thành phố',
              prefixIcon: Icon(Icons.map_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onChanged: vm.setNote,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
              hintText: 'Ví dụ: Giao hàng giờ hành chính',
              prefixIcon: Icon(Icons.note_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(
      CheckoutViewModel vm, CartViewModel cartVM, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Info card
        _InfoCard(
          title: AppStrings.customerInfo,
          rows: [
            _InfoRow('Họ tên', vm.customerName),
            _InfoRow('Điện thoại', vm.customerPhone),
          ],
        ),
        const SizedBox(height: 12),

        // Shipping card
        _InfoCard(
          title: AppStrings.shippingAddress,
          rows: [
            _InfoRow('Địa chỉ', vm.fullShippingAddress),
            if (vm.note.isNotEmpty) _InfoRow('Ghi chú', vm.note),
          ],
        ),
        const SizedBox(height: 12),

        // Payment method
        _InfoCard(
          title: AppStrings.paymentMethod,
          rows: [
            _InfoRow('Hình thức', vm.paymentMethod == 'COD' ? AppStrings.cod : AppStrings.bankTransfer),
          ],
        ),
        const SizedBox(height: 12),

        // Items
        _InfoCard(
          title: 'Sản phẩm (${cartVM.totalItemCount})',
          rows: cartVM.items
              .map((item) => _InfoRow(
                    item.name.length > 30
                        ? '${item.name.substring(0, 30)}...'
                        : item.name,
                    '${item.quantity} x ${AppFormatters.vnd(item.price)}',
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),

        // Total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _TotalRow('Tạm tính', AppFormatters.vnd(cartVM.subtotal)),
              const SizedBox(height: 8),
              _TotalRow(
                AppStrings.shipping,
                cartVM.shippingFee == 0
                    ? 'Miễn phí'
                    : AppFormatters.vnd(cartVM.shippingFee),
              ),
              const Divider(color: Colors.white30, height: 20),
              _TotalRow(
                AppStrings.total,
                AppFormatters.vnd(cartVM.total),
                isBold: true,
              ),
            ],
          ),
        ),

        // Payment options
        const SizedBox(height: 12),
        Consumer<CheckoutViewModel>(
          builder: (_, vm, __) => Column(
            children: [
              _PaymentOption(
                label: AppStrings.cod,
                icon: Icons.money_rounded,
                selected: vm.paymentMethod == 'COD',
                onTap: () => vm.setPaymentMethod('COD'),
              ),
              const SizedBox(height: 8),
              _PaymentOption(
                label: AppStrings.bankTransfer,
                icon: Icons.account_balance_outlined,
                selected: vm.paymentMethod == 'Bank Transfer',
                onTap: () => vm.setPaymentMethod('Bank Transfer'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(
      BuildContext context, CheckoutViewModel vm, CartViewModel cartVM) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          if (vm.currentStep > 0)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: vm.prevStep,
                child: const Text('Quay lại'),
              ),
            ),
          if (vm.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(
                    onPressed: () {
                      if (!_validateCurrentStep(vm.currentStep)) return;
                      if (vm.currentStep < 2) {
                        vm.nextStep();
                      } else {
                        _placeOrder();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vm.currentStep == 2
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                    child: Text(
                      vm.currentStep == 2
                          ? AppStrings.placeOrder
                          : 'Tiếp theo',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Thông tin', 'Địa chỉ', 'Xác nhận'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineActive = currentStep > i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: lineActive ? AppColors.primary : AppColors.borderLight,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final active = stepIdx <= currentStep;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.borderLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: stepIdx < currentStep
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.textHint,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  fontSize: 10,
                  color: active ? AppColors.primary : AppColors.textHint,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white70,
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600)),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : null,
                  )),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
