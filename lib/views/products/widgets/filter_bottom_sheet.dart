import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../viewmodels/product_viewmodel.dart';

/// Filter bottom sheet — filter by category and sort.
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _tempCategory;
  SortOption _tempSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProductViewModel>();
    _tempCategory = vm.selectedCategoryId;
    _tempSort = vm.sortOption;
  }

  void _apply() {
    final vm = context.read<ProductViewModel>();
    vm.filterByCategory(_tempCategory);
    vm.setSortOption(_tempSort);
    Navigator.pop(context);
  }

  void _reset() {
    final vm = context.read<ProductViewModel>();
    vm.clearFilter();
    vm.setSortOption(SortOption.newest);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.read<ProductViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.filter,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: _reset,
                child: const Text('Xóa tất cả',
                    style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          const Text('Danh mục',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                label: 'Tất cả',
                selected: _tempCategory == null,
                onTap: () => setState(() => _tempCategory = null),
              ),
              ...vm.categories.map((cat) => _CategoryChip(
                    label: cat.name,
                    selected: _tempCategory == cat.id,
                    onTap: () => setState(() => _tempCategory = cat.id),
                  )),
            ],
          ),
          const SizedBox(height: 20),

          // Sort
          const Text('Sắp xếp',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortOption.values
                .map((opt) => _SortChip(
                      label: opt.label,
                      selected: _tempSort == opt,
                      onTap: () => setState(() => _tempSort = opt),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('Áp dụng',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends _CategoryChip {
  const _SortChip(
      {required super.label, required super.selected, required super.onTap});
}
