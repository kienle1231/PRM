import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/address_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _provinceCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _wardCtrl;
  late TextEditingController _addressCtrl;
  
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameCtrl = TextEditingController(text: addr?.name ?? '');
    _phoneCtrl = TextEditingController(text: addr?.phone ?? '');
    _provinceCtrl = TextEditingController(text: addr?.province ?? '');
    _districtCtrl = TextEditingController(text: addr?.district ?? '');
    _wardCtrl = TextEditingController(text: addr?.ward ?? '');
    _addressCtrl = TextEditingController(text: addr?.address ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _wardCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authVM = context.read<AuthViewModel>();
    
    final newAddr = AddressModel(
      id: widget.address?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      ward: _wardCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      isDefault: _isDefault,
    );

    bool success;
    if (widget.address == null) {
      success = await authVM.addAddress(newAddr);
    } else {
      success = await authVM.updateAddress(newAddr);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Có lỗi xảy ra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Liên hệ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              validator: AppValidators.fullName,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              validator: AppValidators.phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            
            const SizedBox(height: 24),
            const Text('Địa chỉ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _provinceCtrl,
              validator: (v) => AppValidators.required(v, fieldName: 'Tỉnh/Thành phố'),
              decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _districtCtrl,
              validator: (v) => AppValidators.required(v, fieldName: 'Quận/Huyện'),
              decoration: const InputDecoration(labelText: 'Quận/Huyện'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _wardCtrl,
              validator: (v) => AppValidators.required(v, fieldName: 'Phường/Xã'),
              decoration: const InputDecoration(labelText: 'Phường/Xã'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              validator: (v) => AppValidators.required(v, fieldName: 'Tên đường, Tòa nhà, Số nhà'),
              decoration: const InputDecoration(labelText: 'Tên đường, Tòa nhà, Số nhà'),
            ),
            
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đặt làm địa chỉ mặc định'),
              value: _isDefault,
              onChanged: (val) {
                setState(() => _isDefault = val);
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Hoàn thành', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
