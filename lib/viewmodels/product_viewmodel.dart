import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../repositories/product_repository.dart';

/// Sort options for product listing.
enum SortOption {
  newest('newest', 'Mới nhất'),
  priceAsc('price_asc', 'Giá tăng dần'),
  priceDesc('price_desc', 'Giá giảm dần'),
  rating('rating', 'Đánh giá cao nhất');

  const SortOption(this.value, this.label);
  final String value;
  final String label;
}

/// Manages product listing state: categories, products, search, filter, sort, pagination.
class ProductViewModel extends ChangeNotifier {
  final MockProductRepository _repo;

  // ── State ──────────────────────────────────────────────────────────────────
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _hotDeals = [];
  List<ProductModel> _searchResults = [];
  ProductModel? _selectedProduct;
  List<ProductModel> _relatedProducts = [];

  String? _selectedCategoryId;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  String? _error;

  ProductViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get hotDeals => _hotDeals;
  List<ProductModel> get searchResults => _searchResults;
  ProductModel? get selectedProduct => _selectedProduct;
  List<ProductModel> get relatedProducts => _relatedProducts;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  // ── Load Initial Data ─────────────────────────────────────────────────────
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getFeaturedProducts(),
        _repo.getHotDeals(),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _featuredProducts = results[1] as List<ProductModel>;
      _hotDeals = results[2] as List<ProductModel>;
    } catch (e) {
      _error = 'Không thể tải dữ liệu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load Products (with pagination) ───────────────────────────────────────
  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = refresh;
    _isLoadingMore = !refresh;
    _error = null;
    notifyListeners();

    try {
      final newItems = await _repo.getProducts(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: _sortOption.value,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _products = newItems;
      } else {
        _products.addAll(newItems);
      }
      _hasMore = newItems.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _error = 'Không thể tải sản phẩm';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load next page of products.
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;
    await loadProducts(refresh: false);
  }

  // ── Load Product Detail ───────────────────────────────────────────────────
  Future<void> loadProductDetail(String productId) async {
    _isLoading = true;
    _selectedProduct = null;
    _relatedProducts = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getProductById(productId),
        _repo.getRelatedProducts(productId, _selectedProduct?.categoryId ?? ''),
      ]);
      _selectedProduct = results[0] as ProductModel?;
      // Reload related with actual category
      if (_selectedProduct != null) {
        _relatedProducts = await _repo.getRelatedProducts(
            productId, _selectedProduct!.categoryId);
      }
    } catch (_) {
      _error = 'Không thể tải chi tiết sản phẩm';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    await loadProducts(refresh: true);
  }

  void clearSearch() {
    _searchQuery = '';
    loadProducts(refresh: true);
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts(refresh: true);
  }

  void clearFilter() {
    _selectedCategoryId = null;
    loadProducts(refresh: true);
  }

  // ── Sort ──────────────────────────────────────────────────────────────────
  void setSortOption(SortOption option) {
    _sortOption = option;
    loadProducts(refresh: true);
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    _categories = await _repo.getCategories();
    notifyListeners();
  }
}
