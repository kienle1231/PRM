import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String _databaseName = 'kiencare_auth.db';
  static const int _databaseVersion = 1;
  static const String _profilesTable = 'user_profiles';

  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_profilesTable (
            user_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            avatar TEXT,
            role TEXT NOT NULL,
            is_disabled INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            profile_json TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

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
    final storedProfile = await _getStoredProfile(user.uid);

    return UserModel(
      id: user.uid,
      name: storedProfile?.name ?? user.displayName ?? '',
      email: user.email ?? storedProfile?.email ?? '',
      phone: storedProfile?.phone ?? user.phoneNumber ?? '',
      avatar: storedProfile?.avatar ?? user.photoURL,
      addresses: storedProfile?.addresses ?? [],
      role: storedProfile?.role ?? 'user',
      isDisabled: storedProfile?.isDisabled ?? false,
      createdAt: user.metadata.creationTime ??
          storedProfile?.createdAt ??
          DateTime.now(),
    );
  }

  Future<void> _saveProfile(UserModel user) async {
    try {
      final db = await _db;
      final now = DateTime.now().toIso8601String();

      await db.insert(
        _profilesTable,
        {
          'user_id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'avatar': user.avatar,
          'role': user.role,
          'is_disabled': user.isDisabled ? 1 : 0,
          'created_at': user.createdAt.toIso8601String(),
          'profile_json': jsonEncode(user.toJson()),
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Firebase Auth is the source of truth for account access. A local
      // profile-cache error must not block sign up, sign in, or password reset.
    }
  }

  Future<UserModel?> _getStoredProfile(String userId) async {
    try {
      final db = await _db;
      final rows = await db.query(
        _profilesTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (rows.isEmpty) return null;

      return UserModel.fromJson(
        jsonDecode(rows.first['profile_json'] as String)
            as Map<String, dynamic>,
      );
    } on FormatException {
      try {
        final db = await _db;
        await db.delete(
          _profilesTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
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
