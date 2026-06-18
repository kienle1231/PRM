class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String province;
  final String district;
  final String ward;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.province,
    required this.district,
    required this.ward,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? province,
    String? district,
    String? ward,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'province': province,
      'district': district,
      'ward': ward,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      province: map['province'] as String,
      district: map['district'] as String,
      ward: map['ward'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  String get fullAddress {
    return '$address, $ward, $district, $province';
  }
}
