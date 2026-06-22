import '../models/address_model.dart';
import '../models/user_model.dart';

/// Abstract interface for admin user management operations.
abstract class UserAdminRepository {
  Future<List<UserModel>> getUsers();
  Future<bool> setUserDisabled(String userId, bool disabled);
}

// ── Mock Implementation ────────────────────────────────────────────────────────
/// In-memory user list for development/demo purposes.
/// Replace with a Firebase Firestore implementation for production.
class MockUserAdminRepository implements UserAdminRepository {
  final List<UserModel> _users = [
    UserModel(
      id: 'admin_demo',
      name: 'Quản trị viên',
      email: 'admin@kiencare.vn',
      phone: '0988888888',
      role: 'admin',
      isDisabled: false,
      addresses: [
        AddressModel(
          id: 'addr_admin',
          name: 'Quản trị viên',
          phone: '0988888888',
          address: 'FPT University',
          province: 'Đà Nẵng',
          district: 'Ngũ Hành Sơn',
          ward: 'Hòa Hải',
          isDefault: true,
        )
      ],
      createdAt: DateTime(2024, 1, 1),
    ),
    UserModel(
      id: 'user_demo',
      name: 'Nguyễn Văn An',
      email: 'demo@kiencare.vn',
      phone: '0912345678',
      role: 'user',
      isDisabled: false,
      addresses: [
        AddressModel(
          id: 'addr_1',
          name: 'Nguyễn Văn An',
          phone: '0912345678',
          address: '123 Lê Lợi',
          province: 'TP. Hồ Chí Minh',
          district: 'Quận 1',
          ward: 'Phường Bến Nghé',
          isDefault: true,
        )
      ],
      createdAt: DateTime(2024, 2, 15),
    ),
    UserModel(
      id: 'user_002',
      name: 'Trần Thị Bích',
      email: 'bich.tran@gmail.com',
      phone: '0901234567',
      role: 'user',
      isDisabled: false,
      addresses: [],
      createdAt: DateTime(2024, 3, 10),
    ),
    UserModel(
      id: 'user_003',
      name: 'Lê Hoàng Nam',
      email: 'nam.le@gmail.com',
      phone: '0977654321',
      role: 'user',
      isDisabled: true,
      addresses: [],
      createdAt: DateTime(2024, 4, 5),
    ),
    UserModel(
      id: 'user_004',
      name: 'Phạm Minh Khoa',
      email: 'khoa.pham@gmail.com',
      phone: '0965432109',
      role: 'user',
      isDisabled: false,
      addresses: [],
      createdAt: DateTime(2024, 5, 20),
    ),
    UserModel(
      id: 'user_005',
      name: 'Nguyễn Thị Mai',
      email: 'mai.nguyen@gmail.com',
      phone: '0987654321',
      role: 'user',
      isDisabled: false,
      addresses: [],
      createdAt: DateTime(2024, 6, 1),
    ),
    UserModel(
      id: 'user_006',
      name: 'Võ Quốc Bảo',
      email: 'bao.vo@gmail.com',
      phone: '0912223334',
      role: 'user',
      isDisabled: false,
      addresses: [],
      createdAt: DateTime(2024, 7, 12),
    ),
    UserModel(
      id: 'user_007',
      name: 'Đặng Thị Hương',
      email: 'huong.dang@gmail.com',
      phone: '0933111222',
      role: 'user',
      isDisabled: true,
      addresses: [],
      createdAt: DateTime(2024, 8, 8),
    ),
  ];

  @override
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_users);
  }

  @override
  Future<bool> setUserDisabled(String userId, bool disabled) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx < 0) return false;
    _users[idx] = _users[idx].copyWith(isDisabled: disabled);
    return true;
  }
}

// ── Firebase Implementation stub ───────────────────────────────────────────────
// TODO: Uncomment khi Firebase Firestore được cấu hình
//
// class FirebaseUserAdminRepository implements UserAdminRepository {
//   final _db = FirebaseFirestore.instance;
//
//   @override
//   Future<List<UserModel>> getUsers() async {
//     final snap = await _db.collection('users').get();
//     return snap.docs
//         .map((d) => UserModel.fromJson({'id': d.id, ...d.data()}))
//         .toList();
//   }
//
//   @override
//   Future<bool> setUserDisabled(String userId, bool disabled) async {
//     try {
//       await _db.collection('users').doc(userId).update({'isDisabled': disabled});
//       // Also use Firebase Auth Admin SDK or Cloud Function to actually disable auth
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }
// }
