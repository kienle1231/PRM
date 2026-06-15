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
}

// ── Mock Implementation ────────────────────────────────────────────────────────
class MockProductRepository implements ProductRepository {
  // ── Categories ─────────────────────────────────────────────────────────────
  final List<CategoryModel> _categories = const [
    CategoryModel(id: 'laptops', name: 'Laptop', icon: '💻', imageUrl: AppImages.catLaptop, order: 1, productCount: 6),
    CategoryModel(id: 'gaming_pc', name: 'PC Gaming', icon: '🖥️', imageUrl: AppImages.catGamingPC, order: 2, productCount: 3),
    CategoryModel(id: 'components', name: 'Linh kiện', icon: '⚙️', imageUrl: AppImages.catComponents, order: 3, productCount: 5),
    CategoryModel(id: 'accessories', name: 'Phụ kiện', icon: '🎧', imageUrl: AppImages.catAccessories, order: 4, productCount: 5),
  ];

  // ── Products ───────────────────────────────────────────────────────────────
  late final List<ProductModel> _products = [
    // ── Laptops ──────────────────────────────────────────────────────────────
    ProductModel(
      id: 'lap001', name: 'ASUS VivoBook 15 X515EA', categoryId: 'laptops', categoryName: 'Laptop',
      price: 12500000, originalPrice: 14999000,
      images: [AppImages.laptopAsus1], description: _laptopDesc('ASUS VivoBook 15 X515EA', 'Intel Core i5-1135G7'),
      specs: {'CPU': 'Intel Core i5-1135G7', 'RAM': '8GB DDR4', 'SSD': '512GB NVMe', 'Màn hình': '15.6" FHD IPS', 'GPU': 'Intel Iris Xe', 'Pin': '42Wh', 'OS': 'Windows 11 Home'},
      stock: 15, rating: 4.5, reviewCount: 328, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 1, 10),
    ),
    ProductModel(
      id: 'lap002', name: 'Dell Inspiron 15 3520', categoryId: 'laptops', categoryName: 'Laptop',
      price: 14990000, originalPrice: 16990000,
      images: [AppImages.laptopDell1], description: _laptopDesc('Dell Inspiron 15 3520', 'Intel Core i7-1255U'),
      specs: {'CPU': 'Intel Core i7-1255U', 'RAM': '16GB DDR4', 'SSD': '512GB SSD', 'Màn hình': '15.6" FHD', 'GPU': 'Intel Iris Xe', 'Pin': '54Wh', 'OS': 'Windows 11'},
      stock: 8, rating: 4.7, reviewCount: 215, isFeatured: true,
      createdAt: DateTime(2024, 2, 5),
    ),
    ProductModel(
      id: 'lap003', name: 'HP Pavilion 14-dv2063TU', categoryId: 'laptops', categoryName: 'Laptop',
      price: 11999000, originalPrice: 13499000,
      images: [AppImages.laptopHp1], description: _laptopDesc('HP Pavilion 14', 'Intel Core i5-1235U'),
      specs: {'CPU': 'Intel Core i5-1235U', 'RAM': '8GB DDR4', 'SSD': '256GB SSD', 'Màn hình': '14" FHD IPS', 'GPU': 'Intel Iris Xe', 'OS': 'Windows 11 Home'},
      stock: 20, rating: 4.3, reviewCount: 187, isHotDeal: true,
      createdAt: DateTime(2024, 2, 20),
    ),
    ProductModel(
      id: 'lap004', name: 'Lenovo ThinkPad X1 Carbon Gen 11', categoryId: 'laptops', categoryName: 'Laptop',
      price: 35000000, originalPrice: 40000000,
      images: [AppImages.laptopLenovo1], description: _laptopDesc('ThinkPad X1 Carbon Gen 11', 'Intel Core i7-1365U'),
      specs: {'CPU': 'Intel Core i7-1365U', 'RAM': '16GB LPDDR5', 'SSD': '512GB PCIe 4.0', 'Màn hình': '14" 2.8K OLED', 'Trọng lượng': '1.12kg', 'Pin': '57Wh', 'OS': 'Windows 11 Pro'},
      stock: 5, rating: 4.9, reviewCount: 89, isFeatured: true,
      createdAt: DateTime(2024, 3, 1),
    ),
    ProductModel(
      id: 'lap005', name: 'Apple MacBook Air M2 2023', categoryId: 'laptops', categoryName: 'Laptop',
      price: 28990000, originalPrice: 32990000,
      images: [AppImages.laptopMacbook1], description: 'MacBook Air M2 2023 với chip Apple M2 mạnh mẽ, màn hình Liquid Retina 13.6" và thời lượng pin lên đến 18 giờ. Thiết kế siêu mỏng nhẹ chỉ 1.24kg.',
      specs: {'Chip': 'Apple M2 (8-core CPU, 8-core GPU)', 'RAM': '8GB Unified', 'SSD': '256GB NVMe', 'Màn hình': '13.6" Liquid Retina', 'Pin': 'Lên đến 18 giờ', 'OS': 'macOS Ventura', 'Trọng lượng': '1.24kg'},
      stock: 12, rating: 4.8, reviewCount: 412, isFeatured: true,
      createdAt: DateTime(2024, 3, 15),
    ),
    ProductModel(
      id: 'lap006', name: 'ASUS ROG Zephyrus G14 GA402', categoryId: 'laptops', categoryName: 'Laptop',
      price: 42000000, originalPrice: 47000000,
      images: [AppImages.laptopAsusRog1], description: 'Laptop gaming cao cấp với Ryzen 9 và RTX 4060. Màn hình 14" 165Hz cực mượt cho gaming chuyên nghiệp.',
      specs: {'CPU': 'AMD Ryzen 9 7940HS', 'RAM': '16GB DDR5', 'SSD': '1TB PCIe 4.0', 'Màn hình': '14" QHD 165Hz', 'GPU': 'NVIDIA RTX 4060 8GB', 'Pin': '76Wh', 'OS': 'Windows 11 Home'},
      stock: 7, rating: 4.8, reviewCount: 156, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 4, 1),
    ),

    // ── Gaming PCs ────────────────────────────────────────────────────────────
    ProductModel(
      id: 'pc001', name: 'KienCare Gaming PC Intel i5-12400F + RTX 3060', categoryId: 'gaming_pc', categoryName: 'PC Gaming',
      price: 22000000, originalPrice: 25000000,
      images: [AppImages.gamingPc1], description: 'PC Gaming tầm trung mạnh mẽ, sẵn sàng cho mọi tựa game AAA ở độ phân giải 1080p cao nhất. Bảo hành 24 tháng.',
      specs: {'CPU': 'Intel Core i5-12400F', 'GPU': 'RTX 3060 12GB', 'RAM': '16GB DDR4 3200MHz', 'SSD': '500GB NVMe', 'Case': 'KienCare T1 RGB', 'PSU': '650W 80+ Bronze', 'OS': 'Windows 11 Home'},
      stock: 10, rating: 4.6, reviewCount: 94, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 2, 1),
    ),
    ProductModel(
      id: 'pc002', name: 'KienCare Gaming PC Intel i7-12700F + RTX 3070', categoryId: 'gaming_pc', categoryName: 'PC Gaming',
      price: 32000000, originalPrice: 37000000,
      images: [AppImages.gamingPc2], description: 'PC Gaming high-end đỉnh cao, chạy mọi game 1440p max settings. Tản nhiệt nước 240mm, RGB đồng bộ.',
      specs: {'CPU': 'Intel Core i7-12700F', 'GPU': 'RTX 3070 8GB', 'RAM': '32GB DDR4 3600MHz', 'SSD': '1TB PCIe 4.0', 'Case': 'KienCare T3 Pro RGB', 'PSU': '750W 80+ Gold', 'OS': 'Windows 11 Home'},
      stock: 6, rating: 4.8, reviewCount: 67, isFeatured: true,
      createdAt: DateTime(2024, 3, 1),
    ),
    ProductModel(
      id: 'pc003', name: 'KienCare Gaming PC Ryzen 5 5600X + RX 6700 XT', categoryId: 'gaming_pc', categoryName: 'PC Gaming',
      price: 27000000, originalPrice: 30000000,
      images: [AppImages.gamingPc3], description: 'Cấu hình AMD hoàn hảo cho gaming 1080p/1440p. Ryzen 5 5600X mạnh mẽ kết hợp RX 6700 XT 12GB.',
      specs: {'CPU': 'AMD Ryzen 5 5600X', 'GPU': 'AMD RX 6700 XT 12GB', 'RAM': '16GB DDR4 3200MHz', 'SSD': '500GB NVMe', 'Case': 'KienCare A1 ARGB', 'PSU': '650W 80+ Bronze'},
      stock: 9, rating: 4.7, reviewCount: 52, isHotDeal: true,
      createdAt: DateTime(2024, 3, 15),
    ),

    // ── Components ────────────────────────────────────────────────────────────
    ProductModel(
      id: 'cmp001', name: 'CPU Intel Core i5-13600K Box', categoryId: 'components', categoryName: 'Linh kiện',
      price: 6500000, originalPrice: 7500000,
      images: [AppImages.cpuIntel], description: 'Intel Core i5-13600K 13th Gen, 14 nhân 20 luồng, xung nhịp boost tối đa 5.1GHz. Hiệu năng gaming và đa nhiệm xuất sắc.',
      specs: {'Nhân/Luồng': '14C/20T (6P+8E)', 'Xung nhịp': 'Base 3.5GHz / Boost 5.1GHz', 'Cache': '24MB L3', 'Socket': 'LGA1700', 'TDP': '125W', 'RAM hỗ trợ': 'DDR4/DDR5'},
      stock: 30, rating: 4.9, reviewCount: 203, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 1, 20),
    ),
    ProductModel(
      id: 'cmp002', name: 'RAM Kingston Fury Beast 16GB DDR5 5200MHz', categoryId: 'components', categoryName: 'Linh kiện',
      price: 1890000, originalPrice: 2290000,
      images: [AppImages.ramKingston], description: 'RAM DDR5 Kingston FURY Beast tốc độ 5200MHz, tản nhiệt nhôm mỏng, tương thích EXPO/XMP 3.0.',
      specs: {'Dung lượng': '16GB (1x16GB)', 'Loại': 'DDR5', 'Tốc độ': '5200MHz', 'Timing': 'CL40', 'Điện áp': '1.25V'},
      stock: 45, rating: 4.7, reviewCount: 178,
      createdAt: DateTime(2024, 2, 10),
    ),
    ProductModel(
      id: 'cmp003', name: 'SSD Samsung 970 EVO Plus 1TB NVMe M.2', categoryId: 'components', categoryName: 'Linh kiện',
      price: 2300000, originalPrice: 2799000,
      images: [AppImages.ssdSamsung], description: 'SSD NVMe hàng đầu của Samsung với tốc độ đọc 3500MB/s. Bộ nhớ MLC đáng tin cậy với bảo hành 5 năm.',
      specs: {'Dung lượng': '1TB', 'Giao tiếp': 'PCIe 3.0 x4 NVMe', 'Đọc': '3500 MB/s', 'Ghi': '3300 MB/s', 'NAND': 'Samsung MLC V-NAND', 'Bảo hành': '5 năm'},
      stock: 35, rating: 4.8, reviewCount: 445, isFeatured: true,
      createdAt: DateTime(2024, 1, 5),
    ),
    ProductModel(
      id: 'cmp004', name: 'VGA ASUS ROG STRIX RTX 4060 OC 8GB GDDR6', categoryId: 'components', categoryName: 'Linh kiện',
      price: 11500000, originalPrice: 13000000,
      images: [AppImages.gpuRtx4060], description: 'Card đồ họa RTX 4060 OC với 3 quạt, RGB, DLSS 3.0 và Frame Generation. Gaming 1080p siêu mượt.',
      specs: {'Chip': 'NVIDIA RTX 4060', 'VRAM': '8GB GDDR6', 'Bus': '128-bit', 'Xung nhịp OC': '2625 MHz', 'Cổng': '3x DP 1.4, 1x HDMI 2.1', 'TDP': '115W'},
      stock: 18, rating: 4.8, reviewCount: 132, isHotDeal: true,
      createdAt: DateTime(2024, 3, 5),
    ),
    ProductModel(
      id: 'cmp005', name: 'Mainboard ASUS PRIME B650M-A AX II', categoryId: 'components', categoryName: 'Linh kiện',
      price: 3900000, originalPrice: 4500000,
      images: [AppImages.mainboard], description: 'Bo mạch chủ Micro-ATX socket AM5, hỗ trợ Ryzen 7000 series, 4 khe RAM DDR5, WiFi 6E tích hợp.',
      specs: {'Socket': 'AM5', 'Chipset': 'AMD B650', 'Form Factor': 'Micro-ATX', 'RAM': '4x DDR5, tối đa 128GB', 'PCIe': 'PCIe 5.0 x16', 'WiFi': 'WiFi 6E', 'Bluetooth': '5.3'},
      stock: 22, rating: 4.6, reviewCount: 87,
      createdAt: DateTime(2024, 2, 25),
    ),

    // ── Accessories ───────────────────────────────────────────────────────────
    ProductModel(
      id: 'acc001', name: 'Bàn phím Logitech G915 TKL Lightspeed', categoryId: 'accessories', categoryName: 'Phụ kiện',
      price: 3890000, originalPrice: 4690000,
      images: [AppImages.keyboardG915], description: 'Bàn phím cơ không dây cao cấp, switch GL Tactile mỏng nhẹ, LIGHTSYNC RGB, pin 40 giờ, kết nối LIGHTSPEED.',
      specs: {'Loại': 'Cơ học (GL Tactile)', 'Layout': 'TKL (Tenkeyless)', 'Kết nối': 'LIGHTSPEED / Bluetooth / USB', 'RGB': 'LIGHTSYNC RGB', 'Pin': '40 giờ (không RGB)', 'Bảo hành': '2 năm'},
      stock: 28, rating: 4.8, reviewCount: 267, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 1, 25),
    ),
    ProductModel(
      id: 'acc002', name: 'Chuột Logitech G Pro X Superlight 2', categoryId: 'accessories', categoryName: 'Phụ kiện',
      price: 1890000, originalPrice: 2290000,
      images: [AppImages.mouseGPro], description: 'Chuột gaming pro không dây siêu nhẹ 60g, sensor HERO 2 25K DPI, LIGHTSPEED 1000Hz, pin 95 giờ.',
      specs: {'Cảm biến': 'HERO 2 25K', 'DPI': '100 - 25,600', 'Trọng lượng': '60g', 'Kết nối': 'LIGHTSPEED Wireless', 'Pin': '95 giờ', 'Polling Rate': '1000Hz'},
      stock: 42, rating: 4.9, reviewCount: 389, isFeatured: true,
      createdAt: DateTime(2024, 2, 15),
    ),
    ProductModel(
      id: 'acc003', name: 'Màn hình LG 27GP850-B 27" IPS 165Hz', categoryId: 'accessories', categoryName: 'Phụ kiện',
      price: 7500000, originalPrice: 9000000,
      images: [AppImages.monitorLg], description: 'Monitor gaming 27" 2K QHD IPS 165Hz, thời gian phản hồi 1ms GtG, NVIDIA G-SYNC Compatible, AMD FreeSync Premium.',
      specs: {'Kích thước': '27 inch', 'Độ phân giải': '2560x1440 (QHD)', 'Tần số quét': '165Hz', 'Panel': 'IPS', 'Phản hồi': '1ms GtG', 'HDR': 'HDR10', 'Cổng': '2x HDMI 2.0, 1x DP 1.4'},
      stock: 14, rating: 4.7, reviewCount: 198, isFeatured: true, isHotDeal: true,
      createdAt: DateTime(2024, 3, 10),
    ),
    ProductModel(
      id: 'acc004', name: 'Tai nghe HyperX Cloud Alpha Wireless', categoryId: 'accessories', categoryName: 'Phụ kiện',
      price: 1650000, originalPrice: 1990000,
      images: [AppImages.headsetHyperX], description: 'Tai nghe gaming không dây HyperX Cloud Alpha, driver 50mm dual chamber, pin 300 giờ (kỷ lục ngành).',
      specs: {'Driver': '50mm Dual Chamber', 'Kết nối': '2.4GHz Wireless', 'Tần số âm': '15Hz-21,000Hz', 'Pin': '300 giờ', 'Mic': 'Detachable, Cardioid'},
      stock: 33, rating: 4.6, reviewCount: 312, isHotDeal: true,
      createdAt: DateTime(2024, 2, 5),
    ),
    ProductModel(
      id: 'acc005', name: 'Webcam Logitech C920s HD Pro', categoryId: 'accessories', categoryName: 'Phụ kiện',
      price: 1290000, originalPrice: 1590000,
      images: [AppImages.webcamC920], description: 'Webcam Full HD 1080p 30fps, tự động lấy nét, lọc màu tốt, mic stereo thu âm rõ. Lý tưởng cho WFH và streaming.',
      specs: {'Độ phân giải': 'Full HD 1080p 30fps', 'Lấy nét': 'Tự động', 'FOV': '78°', 'Mic': 'Stereo tích hợp', 'Kết nối': 'USB 2.0', 'Tương thích': 'Windows, Mac, Linux'},
      stock: 55, rating: 4.5, reviewCount: 534,
      createdAt: DateTime(2024, 1, 15),
    ),
  ];

  static String _laptopDesc(String name, String cpu) =>
      '$name với bộ vi xử lý $cpu, màn hình FHD sắc nét, thiết kế mỏng nhẹ, pin bền bỉ. '
      'Lý tưởng cho học tập, làm việc văn phòng và giải trí nhẹ. Bảo hành 12 tháng chính hãng.';

  // ── Repository Methods ──────────────────────────────────────────────────────
  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 400));
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
          p.description.toLowerCase().contains(q)).toList();
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
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Pagination
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    return list.sublist(start, (start + pageSize).clamp(0, list.length));
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.where((p) => p.isFeatured).take(6).toList();
  }

  @override
  Future<List<ProductModel>> getHotDeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.where((p) => p.isHotDeal).take(6).toList();
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(
      String productId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products
        .where((p) => p.categoryId == categoryId && p.id != productId)
        .take(4)
        .toList();
  }
}
