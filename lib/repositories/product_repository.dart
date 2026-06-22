import 'dart:convert';
import 'dart:io';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../core/constants/app_images.dart';

/// Abstract interface for product data operations.
abstract class ProductRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    String sortBy,
    int page,
    int pageSize,
  });
  Future<ProductModel?> getProductById(String id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getHotDeals();
  Future<List<ProductModel>> getRelatedProducts(String productId, String categoryId);

  // ── Admin CRUD ────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getAllProducts();
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

// ── Mock Implementation ────────────────────────────────────────────────────────
class MockProductRepository implements ProductRepository {
  late final List<ProductModel> _products;
  late final List<CategoryModel> _categories;

  MockProductRepository() {
    List<ProductModel>? loadedProducts;
    try {
      final file = File('D:/SU26/PRM393/Project/PRM/laptophub_products.json');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final jsonList = jsonDecode(content) as List;
        loadedProducts = jsonList
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    if (loadedProducts == null || loadedProducts.isEmpty) {
      try {
        final jsonList = jsonDecode(_embeddedProductsJson) as List;
        loadedProducts = jsonList
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        loadedProducts = [];
      }
    }

    _products = loadedProducts;

    // Dynamic product counts for each category slug
    final countGaming = _products.where((p) => p.category == 'gaming').length;
    final countOffice = _products.where((p) => p.category == 'office').length;
    final countBusiness = _products.where((p) => p.category == 'business').length;
    final countConvertible = _products.where((p) => p.category == 'convertible').length;

    _categories = [
      CategoryModel(
        id: 'gaming',
        name: 'Gaming',
        icon: '🎮',
        imageUrl: AppImages.catGamingPC,
        order: 1,
        productCount: countGaming,
      ),
      CategoryModel(
        id: 'office',
        name: 'Văn phòng',
        icon: '💼',
        imageUrl: AppImages.catLaptop,
        order: 2,
        productCount: countOffice,
      ),
      CategoryModel(
        id: 'business',
        name: 'Doanh nhân',
        icon: '👔',
        imageUrl: AppImages.catLaptop,
        order: 3,
        productCount: countBusiness,
      ),
      CategoryModel(
        id: 'convertible',
        name: 'Laptop 2-in-1',
        icon: '🔄',
        imageUrl: AppImages.catLaptop,
        order: 4,
        productCount: countConvertible,
      ),
    ];
  }

  // ── Repository Methods ──────────────────────────────────────────────────────
  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _categories;
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    String sortBy = 'newest',
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = List<ProductModel>.from(_products);

    // Filter by category
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.searchKeywords.any((keyword) => keyword.toLowerCase().contains(q))).toList();
    }

    // Sort
    switch (sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
      default:
        list.sort((a, b) {
          final cmp = b.createdAt.compareTo(a.createdAt);
          if (cmp != 0) return cmp;
          return a.id.compareTo(b.id);
        });
    }

    // Pagination
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    return list.sublist(start, (start + pageSize).clamp(0, list.length));
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isFeatured).take(6).toList();
  }

  @override
  Future<List<ProductModel>> getHotDeals() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products.where((p) => p.isHotDeal).take(6).toList();
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(
      String productId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products
        .where((p) => p.categoryId == categoryId && p.id != productId)
        .take(4)
        .toList();
  }

  // ── Admin CRUD ─────────────────────────────────────────────────────────────
  @override
  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List<ProductModel>.from(_products);
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _products.insert(0, product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _products.removeWhere((p) => p.id == id);
  }
}


const String _embeddedProductsJson = '''[
  {
    "id": "LAP001",
    "name": "Acer Gaming Nitro V 15 ProPanel ANV15-41-R9M1",
    "brand": "Acer",
    "model": "Gaming Nitro V 15 ProPanel ANV15-41-R9M1",
    "category": "gaming",
    "price": 21800000,
    "originalPrice": 22900000,
    "discountPercent": 4,
    "stock": 15,
    "images": [
      "https://techcare.vn/image/acer-gaming-nitro-v-15-propanel-anv15-41-r9m1-6unbs9k.jpg"
    ],
    "description": "Acer Gaming Nitro V 15 ProPanel ANV15-41-R9M1 là laptop gaming tầm trung với AMD Ryzen 5 7535HS và RTX 3050 6GB, màn hình 15.6 inch Full HD 144Hz cho trải nghiệm gaming mượt mà. Thiết kế chắc chắn, tản nhiệt hiệu quả, phù hợp cho game thủ yêu thích hiệu năng cao trong tầm giá hợp lý.",
    "rating": 4.3,
    "reviewCount": 80,
    "isFeatured": true,
    "isNew": true,
    "cpu": "AMD Ryzen 5 7535HS",
    "gpu": "Nvidia GeForce RTX 3050 6GB",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "acer",
      "nitro",
      "gaming",
      "ryzen",
      "rtx 3050",
      "16gb",
      "512gb",
      "laptop gaming",
      "144hz"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP002",
    "name": "Acer Nitro V ANV15-41-R2UP",
    "brand": "Acer",
    "model": "Nitro V ANV15-41-R2UP",
    "category": "gaming",
    "price": 17600000,
    "originalPrice": 19200000,
    "discountPercent": 8,
    "stock": 16,
    "images": [
      "https://techcare.vn/image/acer-nitro-v-15-anv15-41-r2up-9-jhfbs62.jpg"
    ],
    "description": "Acer Nitro V ANV15-41-R2UP trang bị AMD Ryzen 5 6600H và RTX 2050 4GB, màn hình 16 inch Full HD 144Hz sắc nét. Đây là lựa chọn tuyệt vời cho game thủ sinh viên cần hiệu năng đồ họa ổn định với mức giá phải chăng, pin bền và thiết kế gaming trẻ trung.",
    "rating": 4.4,
    "reviewCount": 87,
    "isFeatured": true,
    "isNew": true,
    "cpu": "AMD Ryzen 5 6600H",
    "gpu": "Nvidia GeForce RTX 2050 4GB",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "1920x1080",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "acer",
      "nitro",
      "gaming",
      "ryzen 5",
      "rtx 2050",
      "16gb",
      "512gb",
      "laptop gaming",
      "144hz"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP003",
    "name": "Dell Inspiron 13 5320",
    "brand": "Dell",
    "model": "Inspiron 13 5320",
    "category": "office",
    "price": 13600000,
    "originalPrice": 27400000,
    "discountPercent": 50,
    "stock": 17,
    "images": [
      "https://techcare.vn/image/dell-inspiron-13-5320-15-o9e5exv.jpg"
    ],
    "description": "Dell Inspiron 13 5320 là laptop văn phòng gọn nhẹ với Intel Core i5-1240P hoặc i7-1260P, màn hình 13.3 inch QHD+ sắc nét. Thiết kế mỏng nhẹ, hiệu năng ổn định cho công việc hàng ngày, phù hợp với dân văn phòng và sinh viên cần di chuyển thường xuyên.",
    "rating": 4.5,
    "reviewCount": 94,
    "isFeatured": true,
    "isNew": true,
    "cpu": "Intel Core i5-1240P | Intel Core i7-1260P",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 13.3,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "core i5",
      "core i7",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "qhd"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP004",
    "name": "Dell Inspiron 14 5445 2024",
    "brand": "Dell",
    "model": "Inspiron 14 5445 2024",
    "category": "office",
    "price": 17350000,
    "originalPrice": 17600000,
    "discountPercent": 1,
    "stock": 18,
    "images": [
      "https://techcare.vn/image/dell-inspiron-14-5445-7-20lz3tg.jpg"
    ],
    "description": "Dell Inspiron 14 5445 2024 được trang bị AMD Ryzen 7 8840HS mạnh mẽ và GPU tích hợp Radeon 780M, màn hình 14 inch 2K+ sắc nét. Hiệu năng vượt trội cho công việc văn phòng, sáng tạo nội dung nhẹ và đa nhiệm, kết hợp pin bền và thiết kế thanh lịch.",
    "rating": 4.6,
    "reviewCount": 101,
    "isFeatured": true,
    "isNew": true,
    "cpu": "AMD Ryzen 7 8840HS",
    "gpu": "AMD Radeon 780M",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "ryzen 7",
      "radeon 780m",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "2k"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP005",
    "name": "Dell Inspiron 14 7440 2024 2 in 1",
    "brand": "Dell",
    "model": "Inspiron 14 7440 2024 2 in 1",
    "category": "convertible",
    "price": 17150000,
    "originalPrice": 17400000,
    "discountPercent": 1,
    "stock": 19,
    "images": [
      "https://techcare.vn/image/dell-inspiron-14-7440-8-94d42lg.jpg"
    ],
    "description": "Dell Inspiron 14 7440 2024 2 in 1 là laptop chuyển đổi linh hoạt với Intel Core 5 120U hoặc Core 7 150U, màn hình cảm ứng 14 inch Full HD xoay 360 độ. Thiết kế mỏng nhẹ, hỗ trợ bút cảm ứng, phù hợp cho người dùng năng động cần cả laptop lẫn máy tính bảng.",
    "rating": 4.7,
    "reviewCount": 108,
    "isFeatured": true,
    "isNew": true,
    "cpu": "Intel Core 5 120U | Intel Core 7 150U",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "convertible",
      "2 in 1",
      "cảm ứng",
      "core 5",
      "8gb",
      "512gb",
      "laptop chuyển đổi"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP006",
    "name": "Dell Inspiron 14 Plus 7430",
    "brand": "Dell",
    "model": "Inspiron 14 Plus 7430",
    "category": "office",
    "price": 17000000,
    "originalPrice": 20900000,
    "discountPercent": 18,
    "stock": 20,
    "images": [
      "https://techcare.vn/image/dell-inspiron-14-plus-7430-7-oi9ret3.jpg"
    ],
    "description": "Dell Inspiron 14 Plus 7430 được trang bị Intel Core i5-13420H hoặc i7-13620H, màn hình 14 inch 2.5K sắc nét và SSD 1TB dung lượng lớn. Hiệu năng mạnh mẽ, phù hợp cho công việc văn phòng chuyên nghiệp, xử lý đa nhiệm và lưu trữ dữ liệu khối lượng lớn.",
    "rating": 4.3,
    "reviewCount": 115,
    "isFeatured": true,
    "isNew": true,
    "cpu": "Intel Core i5-13420H | Intel Core i7-13620H",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 1000
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "core i7",
      "16gb",
      "1tb",
      "laptop văn phòng",
      "2.5k"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP007",
    "name": "Dell Inspiron 14 Plus 7440F (2025)",
    "brand": "Dell",
    "model": "Inspiron 14 Plus 7440F (2025)",
    "category": "office",
    "price": 20500000,
    "originalPrice": 23600000,
    "discountPercent": 13,
    "stock": 21,
    "images": [
      "https://techcare.vn/image/dell-inspiron-14-plus-7440f-2025-74ibm8d.jpg"
    ],
    "description": "Dell Inspiron 14 Plus 7440F (2025) là laptop văn phòng cao cấp với Intel Core 5-210H hoặc Core 7-240H thế hệ mới nhất, màn hình 14 inch FHD hoặc QHD 2.5K. Hiệu năng AI vượt trội, RAM 16GB và SSD 512GB đáp ứng tốt mọi nhu cầu làm việc chuyên nghiệp.",
    "rating": 4.4,
    "reviewCount": 122,
    "isFeatured": true,
    "isNew": true,
    "cpu": "Intel Core 5-210H | Intel Core 7-240H",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "core 7",
      "2025",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "qhd"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP008",
    "name": "Dell Inspiron 3530",
    "brand": "Dell",
    "model": "Inspiron 3530",
    "category": "office",
    "price": 15450000,
    "originalPrice": 16900000,
    "discountPercent": 8,
    "stock": 22,
    "images": [
      "https://techcare.vn/image/dell-inspiron-3530-7-ta7btwz.jpg"
    ],
    "description": "Dell Inspiron 3530 là laptop văn phòng phổ thông với Intel Core i5-1335U hoặc i7-1355U, màn hình 15.6 inch Full HD rộng rãi. RAM 8GB hoặc 16GB linh hoạt theo nhu cầu, SSD 512GB nhanh, phù hợp cho sinh viên và nhân viên văn phòng cần thiết bị bền bỉ, đáng tin cậy.",
    "rating": 4.5,
    "reviewCount": 129,
    "isFeatured": true,
    "isNew": true,
    "cpu": "Intel Core i7-1355U | Intel Core i5-1335U",
    "gpu": "Intel UHD Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "core i5",
      "core i7",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "15 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP009",
    "name": "Dell Inspiron 5630",
    "brand": "Dell",
    "model": "Inspiron 5630",
    "category": "office",
    "price": 15190000,
    "originalPrice": 17200000,
    "discountPercent": 11,
    "stock": 23,
    "images": [
      "https://techcare.vn/image/dell-inspiron-5630-11-ri97eun.jpg"
    ],
    "description": "Dell Inspiron 5630 trang bị Intel Core i5-1340P hoặc i7-1360P mạnh mẽ, màn hình 16 inch FHD+ hoặc 2.5K 120Hz cho trải nghiệm hiển thị xuất sắc. SSD 512GB nhanh, thiết kế sang trọng, là lựa chọn lý tưởng cho dân văn phòng cần màn hình lớn và hiệu năng cao.",
    "rating": 4.6,
    "reviewCount": 136,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i5-1340P | Intel Core i7-1360P",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "core i5",
      "core i7",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "16 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP010",
    "name": "Dell Inspiron 7445 2024",
    "brand": "Dell",
    "model": "Inspiron 7445 2024",
    "category": "office",
    "price": 18950000,
    "originalPrice": 19900000,
    "discountPercent": 4,
    "stock": 24,
    "images": [
      "https://techcare.vn/image/dell-inspiron-7445-12-btd438d.jpg"
    ],
    "description": "Dell Inspiron 7445 2024 được trang bị AMD Ryzen 5 7640HS hiệu năng cao, màn hình 14 inch FHD+ cảm ứng trực quan. Thiết kế premium mỏng nhẹ, phù hợp cho người dùng văn phòng và sinh viên cần laptop đa năng có màn hình cảm ứng nhạy bén, pin bền cả ngày làm việc.",
    "rating": 4.7,
    "reviewCount": 143,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 5 7640HS",
    "gpu": "AMD Radeon Graphics",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "inspiron",
      "office",
      "ryzen 5",
      "cảm ứng",
      "8gb",
      "512gb",
      "laptop văn phòng",
      "2024"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP011",
    "name": "Dell Vostro 15 3530",
    "brand": "Dell",
    "model": "Vostro 15 3530",
    "category": "business",
    "price": 12500000,
    "originalPrice": 15200000,
    "discountPercent": 17,
    "stock": 25,
    "images": [
      "https://techcare.vn/image/dell-vostro-15-3530-8-95skezf.jpg"
    ],
    "description": "Dell Vostro 15 3530 là laptop doanh nghiệp giá tốt với Intel Core i5-1334U, màn hình 15.6 inch Full HD rộng rãi và SSD 512GB. Được tối ưu hóa cho môi trường doanh nghiệp với bảo mật tích hợp, hiệu năng ổn định và thiết kế chuyên nghiệp phù hợp mọi không gian làm việc.",
    "rating": 4.3,
    "reviewCount": 150,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i5-1334U",
    "gpu": "Intel UHD Graphics",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "vostro",
      "business",
      "core i5",
      "8gb",
      "512gb",
      "laptop doanh nghiệp",
      "15 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP012",
    "name": "Dell Vostro 3520",
    "brand": "Dell",
    "model": "Vostro 3520",
    "category": "business",
    "price": 9600000,
    "originalPrice": 11700000,
    "discountPercent": 17,
    "stock": 26,
    "images": [
      "https://techcare.vn/image/dell-vostro-3520-7-to3bcqx.jpg"
    ],
    "description": "Dell Vostro 3520 là laptop doanh nghiệp phổ thông với Intel Core i3-1215U, màn hình 15.6 inch Full HD và SSD 256GB. Giá thành hợp lý, hiệu năng đủ dùng cho các tác vụ văn phòng cơ bản, là lựa chọn tiết kiệm ngân sách cho doanh nghiệp vừa và nhỏ.",
    "rating": 4.4,
    "reviewCount": 157,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i3-1215U",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 256
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "dell",
      "vostro",
      "business",
      "core i3",
      "8gb",
      "256gb",
      "laptop doanh nghiệp",
      "giá rẻ"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP013",
    "name": "HP 15 - FD1850T",
    "brand": "HP",
    "model": "15 - FD1850T",
    "category": "office",
    "price": 16990000,
    "originalPrice": 19800000,
    "discountPercent": 14,
    "stock": 27,
    "images": [
      "https://techcare.vn/image/laptop-hp-15-fd1850t-683bc06.jpg?s=3"
    ],
    "description": "HP 15 FD1850T trang bị Intel Core Ultra 5 125H thế hệ mới với Intel Arc Graphics, màn hình 15.6 inch Full HD rộng rãi. Hiệu năng AI tích hợp, xử lý đa nhiệm mượt mà, phù hợp cho nhân viên văn phòng cần laptop hiện đại, bền bỉ và có hiệu năng đồ họa tốt hơn thế hệ trước.",
    "rating": 4.5,
    "reviewCount": 164,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core Ultra 5 125H",
    "gpu": "Intel Arc Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "hp",
      "office",
      "core ultra 5",
      "intel arc",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "15 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP014",
    "name": "HP 15-fc0093dx",
    "brand": "HP",
    "model": "15-fc0093dx",
    "category": "office",
    "price": 11300000,
    "originalPrice": 13800000,
    "discountPercent": 18,
    "stock": 28,
    "images": [
      "https://techcare.vn/image/laptop-hp-15-fc0093dx-blkodtn.jpg?s=3"
    ],
    "description": "HP 15-fc0093dx trang bị AMD Ryzen 5 7520U tiết kiệm điện, màn hình 15.6 inch Full HD và SSD 256GB. Thiết kế gọn nhẹ, pin bền, hiệu năng ổn định cho các tác vụ học tập và làm việc cơ bản, là lựa chọn kinh tế phù hợp cho sinh viên và người dùng phổ thông.",
    "rating": 4.6,
    "reviewCount": 171,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 5 7520U",
    "gpu": "AMD Radeon Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 256
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "hp",
      "office",
      "ryzen 5",
      "16gb",
      "256gb",
      "laptop văn phòng",
      "giá rẻ",
      "sinh viên"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP015",
    "name": "HP Envy X360 14-fa0013dx (2024)",
    "brand": "HP",
    "model": "Envy X360 14-fa0013dx (2024)",
    "category": "convertible",
    "price": 17490000,
    "originalPrice": 18690000,
    "discountPercent": 6,
    "stock": 29,
    "images": [
      "https://techcare.vn/image/laptop-hp-envy-x360-14-fa0013dx-2024-2i5z2zj.jpg?s=3"
    ],
    "description": "HP Envy X360 14-fa0013dx 2024 là laptop 2-in-1 cao cấp với AMD Ryzen 5-8640HS, màn hình 14 inch FHD+ cảm ứng xoay 360 độ. Thiết kế nhôm nguyên khối sang trọng, bút stylus chính xác, phù hợp cho nhà thiết kế và người dùng sáng tạo cần sự linh hoạt.",
    "rating": 4.7,
    "reviewCount": 178,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 5-8640HS",
    "gpu": "AMD Radeon Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "hp",
      "envy",
      "x360",
      "convertible",
      "2 in 1",
      "cảm ứng",
      "ryzen 5",
      "16gb",
      "512gb",
      "laptop chuyển đổi"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP016",
    "name": "HP Envy x360 2 in 1 16-ac0013dx 2024",
    "brand": "HP",
    "model": "Envy x360 2 in 1 16-ac0013dx 2024",
    "category": "convertible",
    "price": 19500000,
    "originalPrice": 21600000,
    "discountPercent": 9,
    "stock": 30,
    "images": [
      "https://techcare.vn/image/laptop-hp-envy-x360-2-in-1-16-ac0013dx-2024-o0av3rq.jpg?s=3"
    ],
    "description": "HP Envy x360 2 in 1 16-ac0013dx 2024 trang bị Intel Core Ultra 5 125U hoặc Core Ultra 7 155U, màn hình 16 inch FHD+ cảm ứng lớn và sắc nét. Thiết kế chuyển đổi linh hoạt, màn hình OLED tùy chọn, phù hợp cho người dùng cần màn hình lớn và đa năng.",
    "rating": 4.3,
    "reviewCount": 185,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core Ultra 5 125U | Intel Core Ultra 7 155U",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "hp",
      "envy",
      "x360",
      "convertible",
      "2 in 1",
      "cảm ứng",
      "core ultra",
      "16gb",
      "512gb",
      "16 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP017",
    "name": "HP Envy x360 2-in-1 14-es1013dx 2024",
    "brand": "HP",
    "model": "Envy x360 2-in-1 14-es1013dx 2024",
    "category": "convertible",
    "price": 15300000,
    "originalPrice": 16200000,
    "discountPercent": 5,
    "stock": 31,
    "images": [
      "https://techcare.vn/image/hp-envy-x360-2-in-1-14-es1013dx-2024-2zek3vi.jpg"
    ],
    "description": "HP Envy x360 2-in-1 14-es1013dx 2024 trang bị Intel Core 5 120U, màn hình 14 inch Full HD cảm ứng xoay 360 độ. Thiết kế mỏng nhẹ, pin bền cả ngày, phù hợp cho sinh viên và người đi làm cần laptop chuyển đổi gọn nhẹ với giá thành hợp lý.",
    "rating": 4.4,
    "reviewCount": 192,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core 5 120U",
    "gpu": "Intel Graphics",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "hp",
      "envy",
      "x360",
      "convertible",
      "2 in 1",
      "cảm ứng",
      "core 5",
      "8gb",
      "512gb",
      "laptop chuyển đổi"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP018",
    "name": "Lenovo IdeaPad Slim 3 2025 (Xiaoxin 16c APH10)",
    "brand": "Lenovo",
    "model": "IdeaPad Slim 3 2025 (Xiaoxin 16c APH10)",
    "category": "office",
    "price": 16690000,
    "originalPrice": 18600000,
    "discountPercent": 10,
    "stock": 32,
    "images": [
      "https://techcare.vn/image/lenovo-ideapad-slim-3-2025-xiaoxin-16c-11-65dboo5.jpg"
    ],
    "description": "Lenovo IdeaPad Slim 3 2025 phiên bản Xiaoxin 16c APH10 trang bị AMD Ryzen 7 8745HS và GPU Radeon 780M tích hợp mạnh mẽ, màn hình 16 inch FHD+ rộng rãi. Hiệu năng xuất sắc trong phân khúc giá, phù hợp cho sinh viên và nhân viên văn phòng cần màn hình lớn.",
    "rating": 4.5,
    "reviewCount": 199,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 7 8745HS",
    "gpu": "AMD Radeon 780M",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "ideapad",
      "slim",
      "office",
      "ryzen 7",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "16 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP019",
    "name": "Lenovo Ideapad Slim 5 2024 (Xiaoxin 14 AHP9)",
    "brand": "Lenovo",
    "model": "Ideapad Slim 5 2024 (Xiaoxin 14 AHP9)",
    "category": "office",
    "price": 18990000,
    "originalPrice": 19200000,
    "discountPercent": 1,
    "stock": 33,
    "images": [
      "https://techcare.vn/image/laptop-lenovo-ideapad-slim-5-2024-rbeg37h.jpg?s=3"
    ],
    "description": "Lenovo IdeaPad Slim 5 2024 phiên bản Xiaoxin 14 AHP9 trang bị AMD Ryzen 7 8845H mạnh mẽ với GPU AMD 780M tích hợp, màn hình 14 inch FHD sắc nét. Thiết kế mỏng nhẹ, hiệu năng cao, pin trâu, lý tưởng cho chuyên gia và sinh viên năng động.",
    "rating": 4.6,
    "reviewCount": 206,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 7 8845H",
    "gpu": "AMD 780M Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "ideapad",
      "slim",
      "office",
      "ryzen 7",
      "16gb",
      "512gb",
      "laptop văn phòng",
      "14 inch"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP020",
    "name": "Lenovo Legion Slim 5 2023 Y7000P",
    "brand": "Lenovo",
    "model": "Legion Slim 5 2023 Y7000P",
    "category": "gaming",
    "price": 27390000,
    "originalPrice": 28100000,
    "discountPercent": 2,
    "stock": 34,
    "images": [
      "https://techcare.vn/image/laptop-lenovo-legion-slim-5-2023-y7000p-2gszez7.jpg?s=3"
    ],
    "description": "Lenovo Legion Slim 5 2023 Y7000P là laptop gaming mỏng nhẹ cao cấp với Intel Core i5/i7 thế hệ 13 và GPU RTX 4050 hoặc RTX 4060, màn hình 16 inch 2.5K sắc nét. Thiết kế thanh lịch, hiệu năng gaming đỉnh cao, phù hợp cho game thủ chuyên nghiệp và nhà sáng tạo.",
    "rating": 4.7,
    "reviewCount": 213,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i5-13500H | Intel Core i7-13620H | Intel Core i7-13700H",
    "gpu": "Nvidia GeForce RTX 4050 6GB | Nvidia GeForce RTX 4060 8GB",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 1000
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "2560x1600",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "legion",
      "gaming",
      "rtx 4060",
      "rtx 4050",
      "16gb",
      "1tb",
      "laptop gaming",
      "2.5k",
      "144hz"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP021",
    "name": "Lenovo LOQ 2024",
    "brand": "Lenovo",
    "model": "LOQ 2024",
    "category": "gaming",
    "price": 22190000,
    "originalPrice": 26290000,
    "discountPercent": 15,
    "stock": 15,
    "images": [
      "https://techcare.vn/image/lenovo-loq-2024-15arp9-92zi2ie.jpg?s=3"
    ],
    "description": "Lenovo LOQ 2024 trang bị AMD Ryzen 7 7435H và RTX 4060 6GB mạnh mẽ, màn hình 15.6 inch Full HD 144Hz mượt mà. Laptop gaming tầm trung với hiệu năng gaming ấn tượng, hệ thống tản nhiệt cải tiến và thiết kế gaming nổi bật, lý tưởng cho game thủ ngân sách hạn chế.",
    "rating": 4.3,
    "reviewCount": 220,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 7 7435H",
    "gpu": "Nvidia GeForce RTX 4060 6GB",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "loq",
      "gaming",
      "ryzen 7",
      "rtx 4060",
      "16gb",
      "512gb",
      "laptop gaming",
      "144hz"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP022",
    "name": "Lenovo Thinkbook 14 G6+ 2024",
    "brand": "Lenovo",
    "model": "Thinkbook 14 G6+ 2024",
    "category": "business",
    "price": 21400000,
    "originalPrice": 22200000,
    "discountPercent": 3,
    "stock": 16,
    "images": [
      "https://techcare.vn/image/laptop-lenovo-thinkbook-14-g6-2024-bfiq3vl.jpg?s=3"
    ],
    "description": "Lenovo ThinkBook 14 G6+ 2024 trang bị Intel Core Ultra 5 125H hoặc Core Ultra 7 155H thế hệ mới nhất với Intel Arc Graphics, màn hình 14.5 inch 2.5K sắc nét và RAM 32GB. Hiệu năng AI vượt trội, lý tưởng cho chuyên gia doanh nghiệp cần laptop cao cấp, mạnh mẽ.",
    "rating": 4.4,
    "reviewCount": 227,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core Ultra 5 125H | Intel Core Ultra 7 155H",
    "gpu": "Intel Arc Graphics",
    "ramGB": 32,
    "storage": {
      "type": "SSD",
      "capacityGB": 1000
    },
    "display": {
      "sizeInch": 14.5,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "thinkbook",
      "business",
      "core ultra 7",
      "intel arc",
      "32gb",
      "1tb",
      "laptop doanh nghiệp",
      "2.5k"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP023",
    "name": "Lenovo Thinkbook 14 G7 2024",
    "brand": "Lenovo",
    "model": "Thinkbook 14 G7 2024",
    "category": "business",
    "price": 17100000,
    "originalPrice": 18700000,
    "discountPercent": 8,
    "stock": 17,
    "images": [
      "https://techcare.vn/image/lenovo-thinkbook-14-g7-2024-rws53tr.jpg?s=3"
    ],
    "description": "Lenovo ThinkBook 14 G7 2024 trang bị AMD Ryzen 7 8845H mạnh mẽ với GPU Radeon 780M, màn hình 14 inch 2K+ sắc nét và SSD 1TB dung lượng lớn. Thiết kế chuyên nghiệp, bảo mật tốt, hiệu năng cao, phù hợp cho doanh nhân cần laptop đa năng và đáng tin cậy.",
    "rating": 4.5,
    "reviewCount": 234,
    "isFeatured": false,
    "isNew": true,
    "cpu": "AMD Ryzen 7 8845H",
    "gpu": "AMD Radeon 780M",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 1000
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "thinkbook",
      "business",
      "ryzen 7",
      "radeon 780m",
      "16gb",
      "1tb",
      "laptop doanh nghiệp",
      "2k"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP024",
    "name": "Lenovo Thinkbook 16 G6+ 2024",
    "brand": "Lenovo",
    "model": "Thinkbook 16 G6+ 2024",
    "category": "business",
    "price": 21500000,
    "originalPrice": 22200000,
    "discountPercent": 3,
    "stock": 18,
    "images": [
      "https://techcare.vn/image/lenovo-thinkbook-16-g6-2024-rgzr4at.jpg?s=3"
    ],
    "description": "Lenovo ThinkBook 16 G6+ 2024 trang bị Intel Core Ultra 7 155H thế hệ mới với Intel Arc Graphics, màn hình 16 inch 2.5K rộng lớn và sắc nét. Màn hình lớn lý tưởng cho làm việc đa nhiệm, thiết kế kỹ thuật, lập trình và dành cho chuyên gia cần không gian hiển thị tối đa.",
    "rating": 4.6,
    "reviewCount": 241,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core Ultra 7 155H",
    "gpu": "Intel Arc Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 16.0,
      "resolution": "2560x1600",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "thinkbook",
      "business",
      "core ultra 7",
      "intel arc",
      "16gb",
      "512gb",
      "laptop doanh nghiệp",
      "16 inch",
      "2.5k"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP025",
    "name": "Lenovo Thinkpad E14 G5",
    "brand": "Lenovo",
    "model": "Thinkpad E14 G5",
    "category": "business",
    "price": 15990000,
    "originalPrice": 16700000,
    "discountPercent": 4,
    "stock": 19,
    "images": [
      "https://techcare.vn/image/laptop-lenovo-thinkpad-e14-g5-24g83x6.jpg?s=3"
    ],
    "description": "Lenovo ThinkPad E14 G5 trang bị Intel Core i5-1335U ổn định và đáng tin cậy, màn hình 14 inch Full HD sắc nét, SSD 512GB nhanh. Được kế thừa truyền thống ThinkPad với bàn phím tuyệt vời, bảo mật cao và độ bền vượt trội, phù hợp cho doanh nghiệp và lập trình viên.",
    "rating": 4.7,
    "reviewCount": 248,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i5-1335U",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1080",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "thinkpad",
      "business",
      "core i5",
      "16gb",
      "512gb",
      "laptop doanh nghiệp",
      "bàn phím tốt"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP026",
    "name": "Lenovo Yoga 7i",
    "brand": "Lenovo",
    "model": "Yoga 7i",
    "category": "convertible",
    "price": 17500000,
    "originalPrice": 19400000,
    "discountPercent": 9,
    "stock": 20,
    "images": [
      "https://techcare.vn/image/laptop-lenovo-yoga-7-rp0x30b.jpg?s=3"
    ],
    "description": "Lenovo Yoga 7i trang bị Intel Core Ultra 5 125H thế hệ mới, màn hình 14 inch FHD+ cảm ứng xoay 360 độ linh hoạt. Thiết kế nhôm nguyên khối sang trọng, bút Lenovo Digital Pen tùy chọn, phù hợp cho nhà thiết kế và người dùng năng động cần sự sáng tạo không giới hạn.",
    "rating": 4.3,
    "reviewCount": 255,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core Ultra 5 125H",
    "gpu": "Intel Iris Xe Graphics",
    "ramGB": 16,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 14.0,
      "resolution": "1920x1200",
      "refreshRate": 60,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "lenovo",
      "yoga",
      "convertible",
      "2 in 1",
      "cảm ứng",
      "core ultra 5",
      "16gb",
      "512gb",
      "laptop chuyển đổi"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP027",
    "name": "MSI Cyborg 15",
    "brand": "MSI",
    "model": "Cyborg 15",
    "category": "gaming",
    "price": 18900000,
    "originalPrice": 25000000,
    "discountPercent": 24,
    "stock": 21,
    "images": [
      "https://techcare.vn/image/laptop-msi-cyborg-15-otmpe0n.jpg?s=3"
    ],
    "description": "MSI Cyborg 15 là laptop gaming thiết kế tương lai với Intel Core i5-12450H và RTX 4050 6GB, màn hình 15.6 inch Full HD 144Hz cực mượt. Vỏ trong suốt độc đáo, RGB ấn tượng, hệ thống tản nhiệt mạnh mẽ, phù hợp cho game thủ muốn thể hiện phong cách riêng.",
    "rating": 4.4,
    "reviewCount": 262,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i5-12450H",
    "gpu": "Nvidia GeForce RTX 4050 6GB",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "msi",
      "cyborg",
      "gaming",
      "core i5",
      "rtx 4050",
      "8gb",
      "512gb",
      "laptop gaming",
      "144hz",
      "rgb"
    ],
    "createdAt": 0,
    "updatedAt": 0
  },
  {
    "id": "LAP028",
    "name": "MSI Thin 15 B13UC 1411VN",
    "brand": "MSI",
    "model": "Thin 15 B13UC 1411VN",
    "category": "gaming",
    "price": 19890000,
    "originalPrice": 21800000,
    "discountPercent": 8,
    "stock": 22,
    "images": [
      "https://techcare.vn/image/laptop-msi-thin-15-b13uc-1411vn-t0sbppw.jpg?s=3"
    ],
    "description": "MSI Thin 15 B13UC 1411VN trang bị Intel Core i7-13620H mạnh mẽ và RTX 3050 4GB GDDR6, màn hình 15.6 inch Full HD 144Hz mượt mà. Thiết kế mỏng nhẹ cho laptop gaming, phù hợp cho game thủ cần hiệu năng gaming tốt trong form factor di động thuận tiện.",
    "rating": 4.5,
    "reviewCount": 269,
    "isFeatured": false,
    "isNew": true,
    "cpu": "Intel Core i7-13620H",
    "gpu": "Nvidia GeForce RTX 3050 4GB GDDR6",
    "ramGB": 8,
    "storage": {
      "type": "SSD",
      "capacityGB": 512
    },
    "display": {
      "sizeInch": 15.6,
      "resolution": "1920x1080",
      "refreshRate": 144,
      "panelType": "IPS"
    },
    "operatingSystem": "Windows 11 Home",
    "color": "đen",
    "weightKg": 2.1,
    "ports": [
      "USB-C",
      "USB-A",
      "HDMI",
      "Audio Jack"
    ],
    "wireless": {
      "wifi": "Wi-Fi 6",
      "bluetooth": "5.2"
    },
    "batteryWh": 54,
    "adapterWatt": 65,
    "warranty": {
      "months": 24,
      "type": "official"
    },
    "condition": "new",
    "searchKeywords": [
      "msi",
      "thin",
      "gaming",
      "core i7",
      "rtx 3050",
      "8gb",
      "512gb",
      "laptop gaming",
      "144hz",
      "mỏng nhẹ"
    ],
    "createdAt": 0,
    "updatedAt": 0
  }
]''';
