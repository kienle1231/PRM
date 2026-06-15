/// User model with copyWith for profile updates.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String? address;
  final String? province;
  final String? district;
  final String? ward;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.address,
    this.province,
    this.district,
    this.ward,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? address,
    String? province,
    String? district,
    String? ward,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        address: address ?? this.address,
        province: province ?? this.province,
        district: district ?? this.district,
        ward: ward ?? this.ward,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'address': address,
        'province': province,
        'district': district,
        'ward': ward,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        avatar: json['avatar'] as String?,
        address: json['address'] as String?,
        province: json['province'] as String?,
        district: json['district'] as String?,
        ward: json['ward'] as String?,
        createdAt: DateTime.parse(
            json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      );
}
