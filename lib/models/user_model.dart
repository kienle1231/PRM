import 'address_model.dart';

/// User model with copyWith for profile updates.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final List<AddressModel> addresses;
  final String role; // 'user' hoặc 'admin'
  final bool isDisabled; // true = tài khoản bị vô hiệu hóa bởi admin
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.addresses = const [],
    this.role = 'user',
    this.isDisabled = false,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    List<AddressModel>? addresses,
    String? role,
    bool? isDisabled,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        addresses: addresses ?? this.addresses,
        role: role ?? this.role,
        isDisabled: isDisabled ?? this.isDisabled,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'role': role,
        'isDisabled': isDisabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        avatar: json['avatar'] as String?,
        addresses: (json['addresses'] as List<dynamic>?)
                ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        role: json['role'] as String? ?? 'user',
        isDisabled: json['isDisabled'] as bool? ?? false,
        createdAt: DateTime.parse(
            json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      );
}
