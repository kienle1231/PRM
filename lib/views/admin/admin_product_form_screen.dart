import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../viewmodels/product_viewmodel.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product; // null = add new

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _originalPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _cpuCtrl;
  late final TextEditingController _gpuCtrl;
  late final TextEditingController _ramCtrl;
  late final TextEditingController _ssdTypeCtrl;
  late final TextEditingController _ssdCapacityCtrl;
  late final TextEditingController _displaySizeCtrl;
  late final TextEditingController _displayResCtrl;
  late final TextEditingController _displayRefreshCtrl;
  late final TextEditingController _displayPanelCtrl;
  late final TextEditingController _osCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _warrantyMonthsCtrl;
  late final TextEditingController _batteryCtrl;
  late final TextEditingController _adapterCtrl;

  String _category = 'gaming';
  String _condition = 'new';
  String _warrantyType = 'official';
  bool _isFeatured = false;
  bool _isNew = true;

  static const _categories = [
    ('Gaming', 'gaming'),
    ('Văn phòng', 'office'),
    ('Doanh nhân', 'business'),
    ('Laptop 2-in-1', 'convertible'),
  ];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _modelCtrl = TextEditingController(text: p?.model ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceCtrl = TextEditingController(text: p?.originalPrice.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '0');
    _imageUrlCtrl = TextEditingController(text: p?.images.firstOrNull ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _cpuCtrl = TextEditingController(text: p?.cpu ?? '');
    _gpuCtrl = TextEditingController(text: p?.gpu ?? '');
    _ramCtrl = TextEditingController(text: p?.ramGB.toString() ?? '8');
    _ssdTypeCtrl = TextEditingController(text: p?.storage.type ?? 'SSD');
    _ssdCapacityCtrl = TextEditingController(text: p?.storage.capacityGB.toString() ?? '512');
    _displaySizeCtrl = TextEditingController(text: p?.display.sizeInch.toString() ?? '15.6');
    _displayResCtrl = TextEditingController(text: p?.display.resolution ?? '1920x1080');
    _displayRefreshCtrl = TextEditingController(text: p?.display.refreshRate.toString() ?? '60');
    _displayPanelCtrl = TextEditingController(text: p?.display.panelType ?? 'IPS');
    _osCtrl = TextEditingController(text: p?.operatingSystem ?? 'Windows 11 Home');
    _colorCtrl = TextEditingController(text: p?.color ?? '');
    _weightCtrl = TextEditingController(text: p?.weightKg.toString() ?? '');
    _warrantyMonthsCtrl = TextEditingController(text: p?.warranty.months.toString() ?? '24');
    _batteryCtrl = TextEditingController(text: p?.batteryWh.toString() ?? '');
    _adapterCtrl = TextEditingController(text: p?.adapterWatt.toString() ?? '');

    if (p != null) {
      _category = p.category;
      _condition = p.condition;
      _warrantyType = p.warranty.type;
      _isFeatured = p.isFeatured;
      _isNew = p.isNew;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _brandCtrl, _modelCtrl, _priceCtrl, _originalPriceCtrl,
      _stockCtrl, _imageUrlCtrl, _descriptionCtrl, _cpuCtrl, _gpuCtrl,
      _ramCtrl, _ssdTypeCtrl, _ssdCapacityCtrl, _displaySizeCtrl,
      _displayResCtrl, _displayRefreshCtrl, _displayPanelCtrl, _osCtrl,
      _colorCtrl, _weightCtrl, _warrantyMonthsCtrl, _batteryCtrl, _adapterCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now().millisecondsSinceEpoch;
    final price = int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;
    final originalPrice = int.tryParse(_originalPriceCtrl.text.replaceAll('.', '')) ?? price;
    final discountPercent = originalPrice > 0
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;

    final product = ProductModel(
      id: widget.product?.id ?? 'ADMIN_${now}',
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      category: _category,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      images: _imageUrlCtrl.text.trim().isNotEmpty ? [_imageUrlCtrl.text.trim()] : [],
      description: _descriptionCtrl.text.trim(),
      rating: widget.product?.rating ?? 0,
      reviewCount: widget.product?.reviewCount ?? 0,
      isFeatured: _isFeatured,
      isNew: _isNew,
      cpu: _cpuCtrl.text.trim(),
      gpu: _gpuCtrl.text.trim(),
      ramGB: int.tryParse(_ramCtrl.text) ?? 8,
      storage: StorageModel(
        type: _ssdTypeCtrl.text.trim(),
        capacityGB: int.tryParse(_ssdCapacityCtrl.text) ?? 512,
      ),
      display: DisplayModel(
        sizeInch: double.tryParse(_displaySizeCtrl.text) ?? 15.6,
        resolution: _displayResCtrl.text.trim(),
        refreshRate: int.tryParse(_displayRefreshCtrl.text) ?? 60,
        panelType: _displayPanelCtrl.text.trim(),
      ),
      operatingSystem: _osCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      weightKg: double.tryParse(_weightCtrl.text) ?? 0,
      ports: ['USB-C', 'USB-A', 'HDMI', 'Audio Jack'],
      wireless: widget.product?.wireless ?? const WirelessModel(wifi: 'Wi-Fi 6', bluetooth: '5.0'),
      batteryWh: int.tryParse(_batteryCtrl.text) ?? 0,
      adapterWatt: int.tryParse(_adapterCtrl.text) ?? 0,
      warranty: WarrantyModel(
        months: int.tryParse(_warrantyMonthsCtrl.text) ?? 24,
        type: _warrantyType,
      ),
      condition: _condition,
      searchKeywords: [
        _brandCtrl.text.toLowerCase(),
        _nameCtrl.text.toLowerCase(),
        _category,
      ],
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    final vm = context.read<ProductViewModel>();
    final ok = _isEditing
        ? await vm.updateProduct(product)
        : await vm.addProduct(product);

    setState(() => _isSaving = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? (_isEditing ? 'Đã cập nhật sản phẩm!' : 'Đã thêm sản phẩm!')
              : 'Có lỗi xảy ra, vui lòng thử lại'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Section: Thông tin cơ bản ────────────────────────────────────
            _SectionHeader(title: '📝 Thông tin cơ bản', icon: Icons.info_outline_rounded),
            const SizedBox(height: 12),
            _FormField(label: 'Tên sản phẩm *', controller: _nameCtrl, required: true),
            _FormField(label: 'Thương hiệu *', controller: _brandCtrl, required: true),
            _FormField(label: 'Model *', controller: _modelCtrl, required: true),
            _FormField(label: 'Mô tả', controller: _descriptionCtrl, maxLines: 4),
            _FormField(label: 'URL ảnh chính', controller: _imageUrlCtrl, keyboardType: TextInputType.url),

            const SizedBox(height: 20),

            // ── Section: Danh mục & Trạng thái ──────────────────────────────
            _SectionHeader(title: '🏷️ Danh mục & Trạng thái', icon: Icons.category_rounded),
            const SizedBox(height: 12),

            // Category dropdown
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  hint: const Text('Chọn danh mục'),
                  items: _categories
                      .map((e) => DropdownMenuItem(
                            value: e.$2,
                            child: Text(e.$1),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
            ),

            // Condition dropdown
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _condition,
                  isExpanded: true,
                  hint: const Text('Tình trạng'),
                  items: const [
                    DropdownMenuItem(value: 'new', child: Text('Mới (New)')),
                    DropdownMenuItem(value: 'used', child: Text('Đã qua sử dụng')),
                    DropdownMenuItem(value: 'refurbished', child: Text('Tân trang lại')),
                  ],
                  onChanged: (v) => setState(() => _condition = v!),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: _SwitchTile(
                    label: 'Nổi bật',
                    value: _isFeatured,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SwitchTile(
                    label: 'Sản phẩm mới',
                    value: _isNew,
                    onChanged: (v) => setState(() => _isNew = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Giá & Tồn kho ───────────────────────────────────────
            _SectionHeader(title: '💰 Giá & Tồn kho', icon: Icons.attach_money_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Giá bán (VNĐ) *',
                    controller: _priceCtrl,
                    required: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Giá gốc (VNĐ)',
                    controller: _originalPriceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            _FormField(
              label: 'Số lượng tồn kho *',
              controller: _stockCtrl,
              required: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),

            // ── Section: Thông số kỹ thuật ───────────────────────────────────
            _SectionHeader(title: '⚙️ Thông số kỹ thuật', icon: Icons.memory_rounded),
            const SizedBox(height: 12),
            _FormField(label: 'CPU *', controller: _cpuCtrl, required: true),
            _FormField(label: 'GPU *', controller: _gpuCtrl, required: true),
            Row(
              children: [
                Expanded(
                    child: _FormField(
                  label: 'RAM (GB) *',
                  controller: _ramCtrl,
                  required: true,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Loại ổ cứng',
                  controller: _ssdTypeCtrl,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Dung lượng (GB)',
                  controller: _ssdCapacityCtrl,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Màn hình ────────────────────────────────────────────
            _SectionHeader(title: '🖥️ Màn hình', icon: Icons.monitor_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _FormField(
                  label: 'Kích thước (inch)',
                  controller: _displaySizeCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Độ phân giải',
                  controller: _displayResCtrl,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _FormField(
                  label: 'Tần số quét (Hz)',
                  controller: _displayRefreshCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Loại tấm nền',
                  controller: _displayPanelCtrl,
                )),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Thông tin khác ──────────────────────────────────────
            _SectionHeader(title: '📦 Thông tin khác', icon: Icons.info_rounded),
            const SizedBox(height: 12),
            _FormField(label: 'Hệ điều hành', controller: _osCtrl),
            Row(
              children: [
                Expanded(child: _FormField(label: 'Màu sắc', controller: _colorCtrl)),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Trọng lượng (kg)',
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _FormField(
                  label: 'Pin (Wh)',
                  controller: _batteryCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _FormField(
                  label: 'Sạc (W)',
                  controller: _adapterCtrl,
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _FormField(
                  label: 'Bảo hành (tháng)',
                  controller: _warrantyMonthsCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _warrantyType,
                        isExpanded: true,
                        hint: const Text('Loại BH'),
                        items: const [
                          DropdownMenuItem(value: 'official', child: Text('Chính hãng')),
                          DropdownMenuItem(value: 'store', child: Text('Cửa hàng')),
                        ],
                        onChanged: (v) => setState(() => _warrantyType = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm sản phẩm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widgets ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F4FF), Color(0xFFF5F0FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE3FF)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF667EEA)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4C63D2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label là bắt buộc' : null
            : null,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
