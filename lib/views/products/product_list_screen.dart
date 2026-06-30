import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../viewmodels/product_viewmodel.dart';
import 'widgets/product_card.dart';
import 'widgets/filter_bottom_sheet.dart';

/// Full product listing with search, filter, sort, and pagination.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _presetCategoryId;
  String? _presetCategoryName;
  String? _presetQuery;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromArgs());
  }

  void _initFromArgs() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _presetCategoryId = args['categoryId'] as String?;
      _presetCategoryName = args['categoryName'] as String?;
      _presetQuery = args['query'] as String?;
    }

    final vm = context.read<ProductViewModel>();
    _searchCtrl.text = _presetQuery ?? '';
    vm.loadProductList(
      categoryId: _presetCategoryId,
      searchQuery: _presetQuery ?? '',
    );
    if (vm.categories.isEmpty) vm.loadCategories();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<ProductViewModel>().loadMoreProducts();
    }
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_presetCategoryName ?? AppStrings.products),
        actions: [
          // Sort button
          Consumer<ProductViewModel>(
            builder: (_, vm, __) => PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: vm.setSortOption,
              itemBuilder: (_) => SortOption.values
                  .map((opt) => PopupMenuItem(
                        value: opt,
                        child: Row(
                          children: [
                            Icon(
                              vm.sortOption == opt
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(opt.label),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilter,
            tooltip: AppStrings.filter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => context.read<ProductViewModel>().search(q),
              onChanged: context.read<ProductViewModel>().setSearchQuery,
              decoration: InputDecoration(
                hintText: AppStrings.productSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ProductViewModel>().clearSearch();
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Active filters chips
          Consumer<ProductViewModel>(
            builder: (_, vm, __) {
              final chips = <Widget>[];
              if (vm.selectedCategoryId != null) {
                final cat = vm.categories.firstWhere(
                  (c) => c.id == vm.selectedCategoryId,
                  orElse: () => vm.categories.first,
                );
                chips.add(_FilterChip(
                  label: cat.name,
                  onRemove: () => vm.clearFilter(),
                ));
              }
              if (vm.sortOption != SortOption.newest) {
                chips.add(_FilterChip(
                  label: vm.sortOption.label,
                  onRemove: () => vm.setSortOption(SortOption.newest),
                ));
              }
              if (chips.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: chips,
                ),
              );
            },
          ),

          // Product Grid
          Expanded(
            child: Consumer<ProductViewModel>(
              builder: (_, vm, __) {
                if (vm.isProductListLoading && vm.products.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                if (vm.products.isEmpty && !vm.isProductListLoading) {
                  return _buildEmptyState(isDark);
                }
                return GridView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.64,
                  ),
                  itemCount: vm.products.length + (vm.isLoadingMore ? 2 : 0),
                  itemBuilder: (_, i) {
                    if (i >= vm.products.length) {
                      return const _ProductCardShimmer();
                    }
                    return ProductCard(product: vm.products[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 72, color: isDark ? Colors.white38 : AppColors.textHint),
          const SizedBox(height: 16),
          const Text(AppStrings.noProductsFound,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Thử tìm với từ khóa khác',
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        backgroundColor: AppColors.primarySurface,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        side: const BorderSide(color: AppColors.primary, width: 0.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child:
            CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      ),
    );
  }
}
