import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/address_model.dart';

/// Authentication contract used by the app and test doubles.
abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
  );
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(UserModel updatedUser);
}

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

/// Production authentication backed by Firebase Authentication.
///
/// Firebase stores credentials and sessions. Extra profile fields that are not
/// part of Firebase Auth are stored locally per Firebase uid.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    Future<SharedPreferences> Function()? preferences,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _preferences = preferences ?? SharedPreferences.getInstance;

  final FirebaseAuth _auth;
  final Future<SharedPreferences> Function() _preferences;

  static const String _profilePrefix = 'auth_profile_';

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Không thể lấy thông tin tài khoản.');
      }
      return _toUserModel(user);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  @override
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthFailure('Không thể tạo tài khoản.');
      }

      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();
      final refreshedUser = _auth.currentUser ?? firebaseUser;
      final user = UserModel(
        id: refreshedUser.uid,
        name: name,
        email: refreshedUser.email ?? email,
        phone: phone,
        avatar: refreshedUser.photoURL,
        createdAt: refreshedUser.metadata.creationTime ?? DateTime.now(),
      );
      await _saveProfile(user);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _auth.setLanguageCode('vi');
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _toUserModel(_auth.currentUser ?? user);
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != updatedUser.id) {
      throw const AuthFailure('Phiên đăng nhập đã hết hạn.');
    }

    try {
      await firebaseUser.updateDisplayName(updatedUser.name);
      if (updatedUser.avatar != firebaseUser.photoURL) {
        await firebaseUser.updatePhotoURL(updatedUser.avatar);
      }
      await _saveProfile(updatedUser);
      return updatedUser;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  Future<UserModel> _toUserModel(User user) async {
    final prefs = await _preferences();
    final rawProfile = prefs.getString('$_profilePrefix${user.uid}');
    UserModel? storedProfile;
    if (rawProfile != null) {
      try {
        storedProfile = UserModel.fromJson(
          jsonDecode(rawProfile) as Map<String, dynamic>,
        );
      } on FormatException {
        await prefs.remove('$_profilePrefix${user.uid}');
      }
    }

    return UserModel(
      id: user.uid,
      name: storedProfile?.name ?? user.displayName ?? '',
      email: user.email ?? storedProfile?.email ?? '',
      phone: storedProfile?.phone ?? user.phoneNumber ?? '',
      avatar: storedProfile?.avatar ?? user.photoURL,
      addresses: storedProfile?.addresses ?? [],
      createdAt: user.metadata.creationTime ??
          storedProfile?.createdAt ??
          DateTime.now(),
    );
  }

  Future<void> _saveProfile(UserModel user) async {
    final prefs = await _preferences();
    await prefs.setString(
      '$_profilePrefix${user.id}',
      jsonEncode(user.toJson()),
    );
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Tài khoản không tồn tại.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu chưa đủ mạnh.';
      case 'operation-not-allowed':
        return 'Đăng nhập bằng email/mật khẩu chưa được bật trên Firebase.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.';
      default:
        return error.message ?? 'Xác thực thất bại. Vui lòng thử lại.';
    }
  }
}

/// In-memory implementation used only by tests and local previews.
class MockAuthRepository implements AuthRepository {
  final Map<String, Map<String, dynamic>> _users = {
    'demo@kiencare.vn': {
      'password': 'KienCare1',
      'user': UserModel(
        id: 'user_demo',
        name: 'Nguyễn Văn An',
        email: 'demo@kiencare.vn',
        phone: '0912345678',
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
        createdAt: DateTime(2024),
      ),
    },
    'admin@kiencare.vn': {
      'password': 'KienCare1',
      'user': UserModel(
        id: 'admin_demo',
        name: 'Quản trị viên',
        email: 'admin@kiencare.vn',
        phone: '0988888888',
        role: 'admin',
        addresses: [
          AddressModel(
            id: 'addr_2',
            name: 'Quản trị viên',
            phone: '0988888888',
            address: 'FPT University',
            province: 'Đà Nẵng',
            district: 'Ngũ Hành Sơn',
            ward: 'Hòa Hải',
            isDefault: true,
          )
        ],
        createdAt: DateTime(2024),
      ),
    },
  };

  UserModel? _currentUser;

  @override
  Future<UserModel> signIn(String email, String password) async {
    final entry = _users[email.toLowerCase()];
    if (entry == null || entry['password'] != password) {
      throw const AuthFailure('Email hoặc mật khẩu không đúng.');
    }
    _currentUser = entry['user'] as UserModel;
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    if (_users.containsKey(email.toLowerCase())) {
      throw const AuthFailure('Email này đã được đăng ký.');
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
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_users.containsKey(email.toLowerCase())) {
      throw const AuthFailure('Email không tồn tại trong hệ thống.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    final entry = _users[updatedUser.email.toLowerCase()];
    if (entry != null) entry['user'] = updatedUser;
    return updatedUser;
  }
}
