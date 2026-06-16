import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/models/user_model.dart';
import 'package:untitled2/repositories/auth_repository.dart';
import 'package:untitled2/viewmodels/auth_viewmodel.dart';

void main() {
  final user = UserModel(
    id: 'user-1',
    name: 'Nguyen Van A',
    email: 'user@example.com',
    phone: '0912345678',
    createdAt: _fixedDate,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('register authenticates the newly created user', () async {
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository);

    final success = await viewModel.register(
      user.name,
      user.email,
      'Password1',
      user.phone,
    );

    expect(success, isTrue);
    expect(viewModel.status, AuthStatus.authenticated);
    expect(viewModel.currentUser, user);
    expect(repository.signUpCalls, 1);
  });

  test('login with remember me stores preference and email', () async {
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository)..setRememberMe(true);

    final success = await viewModel.login(user.email, 'Password1');
    final prefs = await SharedPreferences.getInstance();

    expect(success, isTrue);
    expect(viewModel.status, AuthStatus.authenticated);
    expect(prefs.getBool('remember_me'), isTrue);
    expect(prefs.getString('saved_email'), user.email);
  });

  test('login without remember me removes stale preference', () async {
    SharedPreferences.setMockInitialValues({
      'remember_me': true,
      'saved_email': 'old@example.com',
    });
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository);

    final success = await viewModel.login(user.email, 'Password1');
    final prefs = await SharedPreferences.getInstance();

    expect(success, isTrue);
    expect(prefs.containsKey('remember_me'), isFalse);
    expect(prefs.containsKey('saved_email'), isFalse);
  });

  test('initialize restores Firebase session when remember me is enabled',
      () async {
    SharedPreferences.setMockInitialValues({'remember_me': true});
    final repository = FakeAuthRepository(user: user, currentUser: user);
    final viewModel = AuthViewModel(repository);

    await viewModel.initialize();

    expect(viewModel.status, AuthStatus.authenticated);
    expect(viewModel.currentUser, user);
    expect(repository.getCurrentUserCalls, 1);
    expect(repository.signOutCalls, 0);
  });

  test('initialize signs out persisted Firebase session when not remembered',
      () async {
    final repository = FakeAuthRepository(user: user, currentUser: user);
    final viewModel = AuthViewModel(repository);

    await viewModel.initialize();

    expect(viewModel.status, AuthStatus.unauthenticated);
    expect(viewModel.currentUser, isNull);
    expect(repository.signOutCalls, 1);
  });

  test('logout clears session and saved remember-me data', () async {
    SharedPreferences.setMockInitialValues({
      'remember_me': true,
      'saved_email': user.email,
    });
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository)..setRememberMe(true);
    await viewModel.login(user.email, 'Password1');

    await viewModel.logout();
    final prefs = await SharedPreferences.getInstance();

    expect(viewModel.status, AuthStatus.unauthenticated);
    expect(viewModel.currentUser, isNull);
    expect(viewModel.rememberMe, isFalse);
    expect(repository.signOutCalls, 1);
    expect(prefs.containsKey('remember_me'), isFalse);
    expect(prefs.containsKey('saved_email'), isFalse);
  });

  test('forgot password delegates to repository', () async {
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository);

    final success = await viewModel.sendPasswordReset(user.email);

    expect(success, isTrue);
    expect(repository.passwordResetEmail, user.email);
  });

  test('authentication errors are exposed to the UI', () async {
    final repository = FakeAuthRepository(
      user: user,
      failure: const AuthFailure('Email hoặc mật khẩu không đúng.'),
    );
    final viewModel = AuthViewModel(repository);

    final success = await viewModel.login(user.email, 'wrong');

    expect(success, isFalse);
    expect(viewModel.status, AuthStatus.unauthenticated);
    expect(viewModel.errorMessage, 'Email hoặc mật khẩu không đúng.');
  });
}

final _fixedDate = DateTime.utc(2026);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.user,
    this.currentUser,
    this.failure,
  });

  final UserModel user;
  final AuthFailure? failure;
  UserModel? currentUser;

  int signUpCalls = 0;
  int signOutCalls = 0;
  int getCurrentUserCalls = 0;
  String? passwordResetEmail;

  void _throwIfNeeded() {
    if (failure != null) throw failure!;
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    _throwIfNeeded();
    currentUser = user;
    return user;
  }

  @override
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    _throwIfNeeded();
    signUpCalls++;
    currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _throwIfNeeded();
    signOutCalls++;
    currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _throwIfNeeded();
    passwordResetEmail = email;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    _throwIfNeeded();
    getCurrentUserCalls++;
    return currentUser;
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    _throwIfNeeded();
    currentUser = updatedUser;
    return updatedUser;
  }
}
