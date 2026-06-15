import '../models/user_model.dart';

/// Abstract interface for authentication operations.
/// Implementations: [MockAuthRepository] (default), FirebaseAuthRepository.
abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String name, String email, String password, String phone);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
}

// ── Mock Implementation ────────────────────────────────────────────────────────
/// In-memory mock repository — works without Firebase.
class MockAuthRepository implements AuthRepository {
  /// In-memory user store: email → {password, user}
  final Map<String, Map<String, dynamic>> _users = {
    'demo@kiencare.vn': {
      'password': 'KienCare1',
      'user': UserModel(
        id: 'user_demo',
        name: 'Nguyễn Văn An',
        email: 'demo@kiencare.vn',
        phone: '0912345678',
        avatar: null,
        address: '123 Lê Lợi',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        createdAt: DateTime(2024, 1, 1),
      ),
    },
  };

  UserModel? _currentUser;

  @override
  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    final entry = _users[email.toLowerCase()];
    if (entry == null) {
      throw Exception('Tài khoản không tồn tại. Vui lòng đăng ký.');
    }
    if (entry['password'] != password) {
      throw Exception('Mật khẩu không đúng. Vui lòng thử lại.');
    }
    _currentUser = entry['user'] as UserModel;
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp(
      String name, String email, String password, String phone) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_users.containsKey(email.toLowerCase())) {
      throw Exception('Email này đã được đăng ký. Vui lòng đăng nhập.');
    }
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );
    _users[email.toLowerCase()] = {'password': password, 'user': user};
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_users.containsKey(email.toLowerCase())) {
      throw Exception('Email không tồn tại trong hệ thống.');
    }
    // In production, Firebase sends the reset email automatically.
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  /// Update user profile (mock)
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = updatedUser;
    final entry = _users[updatedUser.email.toLowerCase()];
    if (entry != null) {
      entry['user'] = updatedUser;
    }
    return updatedUser;
  }
}

// ── Firebase Implementation Stub ───────────────────────────────────────────────
// TODO: Firebase — Uncomment and implement when Firebase is configured
// class FirebaseAuthRepository implements AuthRepository {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   @override
//   Future<UserModel> signIn(String email, String password) async {
//     final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
//     return await _getUserFromFirestore(cred.user!.uid);
//   }
//
//   @override
//   Future<UserModel> signUp(String name, String email, String password, String phone) async {
//     final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//     final user = UserModel(id: cred.user!.uid, name: name, email: email, phone: phone, createdAt: DateTime.now());
//     await _db.collection('users').doc(user.id).set(user.toJson());
//     return user;
//   }
//
//   @override
//   Future<void> signOut() => _auth.signOut();
//
//   @override
//   Future<void> sendPasswordResetEmail(String email) =>
//       _auth.sendPasswordResetEmail(email: email);
//
//   @override
//   Future<UserModel?> getCurrentUser() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;
//     return await _getUserFromFirestore(user.uid);
//   }
//
//   Future<UserModel> _getUserFromFirestore(String uid) async {
//     final doc = await _db.collection('users').doc(uid).get();
//     return UserModel.fromJson({'id': uid, ...doc.data()!});
//   }
// }
