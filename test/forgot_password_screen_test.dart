import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/models/user_model.dart';
import 'package:untitled2/repositories/auth_repository.dart';
import 'package:untitled2/viewmodels/auth_viewmodel.dart';
import 'package:untitled2/views/auth/forgot_password_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('submits email and shows password reset success state',
      (tester) async {
    final repository = _PasswordResetRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(repository),
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'user@example.com',
    );
    await tester.tap(find.text('Gửi link đặt lại'));
    await tester.pumpAndSettle();

    expect(repository.submittedEmail, 'user@example.com');
    expect(find.text('Đã tiếp nhận yêu cầu'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
  });

  testWidgets('rejects invalid email before calling repository',
      (tester) async {
    final repository = _PasswordResetRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(repository),
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'invalid-email');
    await tester.tap(find.text('Gửi link đặt lại'));
    await tester.pump();

    expect(repository.submittedEmail, isNull);
    expect(find.text('Email không hợp lệ'), findsOneWidget);
  });
}

class _PasswordResetRepository implements AuthRepository {
  String? submittedEmail;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    submittedEmail = email;
  }

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel> signIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) {
    throw UnimplementedError();
  }
}
