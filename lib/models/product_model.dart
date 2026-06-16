
class StorageModel {
  final String type;
  final int capacityGB;

  const StorageModel({
    required this.type,
    required this.capacityGB,
  });

  factory StorageModel.fromJson(Map<String, dynamic> json) => StorageModel(
        type: json['type'] as String? ?? 'SSD',
        capacityGB: json['capacityGB'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'capacityGB': capacityGB,
      };

  StorageModel copyWith({
    String? type,
    int? capacityGB,
  }) =>
      StorageModel(
        type: type ?? this.type,
        capacityGB: capacityGB ?? this.capacityGB,
      );
}

class DisplayModel {
  final double sizeInch;
  final String resolution;
  final int refreshRate;
  final String panelType;

  const DisplayModel({
    required this.sizeInch,
    required this.resolution,
    required this.refreshRate,
    required this.panelType,
  });

  factory DisplayModel.fromJson(Map<String, dynamic> json) => DisplayModel(
        sizeInch: (json['sizeInch'] as num? ?? 0.0).toDouble(),
        resolution: json['resolution'] as String? ?? '',
        refreshRate: json['refreshRate'] as int? ?? 0,
        panelType: json['panelType'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'sizeInch': sizeInch,
        'resolution': resolution,
        'refreshRate': refreshRate,
        'panelType': panelType,
      };

  DisplayModel copyWith({
    double? sizeInch,
    String? resolution,
    int? refreshRate,
    String? panelType,
  }) =>
      DisplayModel(
        sizeInch: sizeInch ?? this.sizeInch,
        resolution: resolution ?? this.resolution,
        refreshRate: refreshRate ?? this.refreshRate,
        panelType: panelType ?? this.panelType,
      );
}

class WirelessModel {
  final String wifi;
  final String bluetooth;

  const WirelessModel({
    required this.wifi,
    required this.bluetooth,
  });

  factory WirelessModel.fromJson(Map<String, dynamic> json) => WirelessModel(
        wifi: json['wifi'] as String? ?? '',
        bluetooth: json['bluetooth'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'wifi': wifi,
        'bluetooth': bluetooth,
      };

  WirelessModel copyWith({
    String? wifi,
    String? bluetooth,
  }) =>
      WirelessModel(
        wifi: wifi ?? this.wifi,
        bluetooth: bluetooth ?? this.bluetooth,
      );
}

class WarrantyModel {
  final int months;
  final String type;

  const WarrantyModel({
    required this.months,
    required this.type,
  });

  factory WarrantyModel.fromJson(Map<String, dynamic> json) => WarrantyModel(
        months: json['months'] as int? ?? 0,
        type: json['type'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'months': months,
        'type': type,
      };

  WarrantyModel copyWith({
    int? months,
    String? type,
  }) =>
      WarrantyModel(
        months: months ?? this.months,
        type: type ?? this.type,
      );
}

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String category;

  final int price;
  final int originalPrice;
  final int discountPercent;

  final int stock;
  final List<String> images;
  final String description;

  final double rating;
  final int reviewCount;

  final bool isFeatured;
  final bool isNew;

  final String cpu;
  final String gpu;
  final int ramGB;
  final StorageModel storage;
  final DisplayModel display;
  final String operatingSystem;
  final String color;
  final double weightKg;
  final List<String> ports;
  final WirelessModel wireless;
  final int batteryWh;
  final int adapterWatt;
  final WarrantyModel warranty;
  final String condition;
  final List<String> searchKeywords;
  final int createdAt;
  final int updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.stock,
    required this.images,
    required this.description,
    required this.rating,
    required this.reviewCount,
    this.isFeatured = false,
    this.isNew = false,
    required this.cpu,
    required this.gpu,
    required this.ramGB,
    required this.storage,
    required this.display,
    required this.operatingSystem,
    required this.color,
    required this.weightKg,
    required this.ports,
    required this.wireless,
    required this.batteryWh,
    required this.adapterWatt,
    required this.warranty,
    required this.condition,
    required this.searchKeywords,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Computed Properties ───────────────────────────────────────────────────
  String get primaryImage => images.isNotEmpty ? images.first : '';

  bool get inStock => stock > 0;

  bool get hasDiscount => originalPrice > price;

  // Let's compute isHotDeal: discountPercent >= 8
  bool get isHotDeal => discountPercent >= 8;

  // Preserve categoryId and categoryName for UI compatibility
  String get categoryId => category;

  String get categoryName {
    switch (category) {
      case 'gaming':
        return 'Gaming';
      case 'office':
        return 'Văn phòng';
      case 'business':
        return 'Doanh nhân';
      case 'student':
        return 'Sinh viên';
      case 'creator':
        return 'Đồ họa / Sáng tạo';
      case 'workstation':
        return 'Trạm (Workstation)';
      case 'ultrabook':
        return 'Ultrabook';
      case 'convertible':
        return 'Laptop 2-in-1';
      default:
        return category.toUpperCase();
    }
  }

  // Preserve specs map so details table keeps working perfectly
  Map<String, String> get specs => {
        'Thương hiệu': brand,
        'Model': model,
        'CPU': cpu,
        'GPU': gpu,
        'RAM': '${ramGB}GB',
        'Lưu trữ': '${storage.type} ${storage.capacityGB}GB',
        'Màn hình': '${display.sizeInch}" ${display.resolution} ${display.refreshRate}Hz ${display.panelType}',
        'Hệ điều hành': operatingSystem,
        'Màu sắc': color,
        'Trọng lượng': '${weightKg}kg',
        'Cổng kết nối': ports.join(', '),
        'WiFi': wireless.wifi,
        'Bluetooth': wireless.bluetooth,
        'Pin': '${batteryWh}Wh',
        'Sạc': '${adapterWatt}W',
        'Bảo hành': '${warranty.months} tháng (${warranty.type == "official" ? "chính hãng" : "cửa hàng"})',
        'Tình trạng': condition == 'new'
            ? 'Mới (New)'
            : (condition == 'used' ? 'Đã qua sử dụng (Used)' : 'Trôi bảo hành (Refurbished)'),
      };

  double get savingsAmount => (originalPrice - price).toDouble();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'model': model,
        'category': category,
        'price': price,
        'originalPrice': originalPrice,
        'discountPercent': discountPercent,
        'stock': stock,
        'images': images,
        'description': description,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
        'isNew': isNew,
        'cpu': cpu,
        'gpu': gpu,
        'ramGB': ramGB,
        'storage': storage.toJson(),
        'display': display.toJson(),
        'operatingSystem': operatingSystem,
        'color': color,
        'weightKg': weightKg,
        'ports': ports,
        'wireless': wireless.toJson(),
        'batteryWh': batteryWh,
        'adapterWatt': adapterWatt,
        'warranty': warranty.toJson(),
        'condition': condition,
        'searchKeywords': searchKeywords,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        model: json['model'] as String? ?? '',
        category: json['category'] as String? ?? '',
        price: json['price'] as int? ?? 0,
        originalPrice: json['originalPrice'] as int? ?? 0,
        discountPercent: json['discountPercent'] as int? ?? 0,
        stock: json['stock'] as int? ?? 0,
        images: List<String>.from(json['images'] as List? ?? []),
        description: json['description'] as String? ?? '',
        rating: (json['rating'] as num? ?? 0.0).toDouble(),
        reviewCount: json['reviewCount'] as int? ?? 0,
        isFeatured: json['isFeatured'] as bool? ?? false,
        isNew: json['isNew'] as bool? ?? false,
        cpu: json['cpu'] as String? ?? '',
        gpu: json['gpu'] as String? ?? '',
        ramGB: json['ramGB'] as int? ?? 0,
        storage: StorageModel.fromJson(json['storage'] as Map<String, dynamic>? ?? {}),
        display: DisplayModel.fromJson(json['display'] as Map<String, dynamic>? ?? {}),
        operatingSystem: json['operatingSystem'] as String? ?? '',
        color: json['color'] as String? ?? '',
        weightKg: (json['weightKg'] as num? ?? 0.0).toDouble(),
        ports: List<String>.from(json['ports'] as List? ?? []),
        wireless: WirelessModel.fromJson(json['wireless'] as Map<String, dynamic>? ?? {}),
        batteryWh: json['batteryWh'] as int? ?? 0,
        adapterWatt: json['adapterWatt'] as int? ?? 0,
        warranty: WarrantyModel.fromJson(json['warranty'] as Map<String, dynamic>? ?? {}),
        condition: json['condition'] as String? ?? 'new',
        searchKeywords: List<String>.from(json['searchKeywords'] as List? ?? []),
        createdAt: json['createdAt'] as int? ?? 0,
        updatedAt: json['updatedAt'] as int? ?? 0,
      );

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? category,
    int? price,
    int? originalPrice,
    int? discountPercent,
    int? stock,
    List<String>? images,
    String? description,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isNew,
    String? cpu,
    String? gpu,
    int? ramGB,
    StorageModel? storage,
    DisplayModel? display,
    String? operatingSystem,
    String? color,
    double? weightKg,
    List<String>? ports,
    WirelessModel? wireless,
    int? batteryWh,
    int? adapterWatt,
    WarrantyModel? warranty,
    String? condition,
    List<String>? searchKeywords,
    int? createdAt,
    int? updatedAt,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        category: category ?? this.category,
        price: price ?? this.price,
        originalPrice: originalPrice ?? this.originalPrice,
        discountPercent: discountPercent ?? this.discountPercent,
        stock: stock ?? this.stock,
        images: images ?? this.images,
        description: description ?? this.description,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isFeatured: isFeatured ?? this.isFeatured,
        isNew: isNew ?? this.isNew,
        cpu: cpu ?? this.cpu,
        gpu: gpu ?? this.gpu,
        ramGB: ramGB ?? this.ramGB,
        storage: storage ?? this.storage,
        display: display ?? this.display,
        operatingSystem: operatingSystem ?? this.operatingSystem,
        color: color ?? this.color,
        weightKg: weightKg ?? this.weightKg,
        ports: ports ?? this.ports,
        wireless: wireless ?? this.wireless,
        batteryWh: batteryWh ?? this.batteryWh,
        adapterWatt: adapterWatt ?? this.adapterWatt,
        warranty: warranty ?? this.warranty,
        condition: condition ?? this.condition,
        searchKeywords: searchKeywords ?? this.searchKeywords,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
