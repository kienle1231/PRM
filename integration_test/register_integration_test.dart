import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/app/routes.dart';
import 'package:untitled2/models/cart_item_model.dart';
import 'package:untitled2/models/notification_model.dart';
import 'package:untitled2/models/order_model.dart';
import 'package:untitled2/repositories/auth_repository.dart';
import 'package:untitled2/repositories/cart_repository.dart';
import 'package:untitled2/repositories/notification_repository.dart';
import 'package:untitled2/repositories/order_repository.dart';
import 'package:untitled2/viewmodels/auth_viewmodel.dart';
import 'package:untitled2/viewmodels/cart_viewmodel.dart';
import 'package:untitled2/viewmodels/notification_viewmodel.dart';
import 'package:untitled2/viewmodels/order_viewmodel.dart';
import 'package:untitled2/views/auth/register_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('đăng ký thành công và chuyển đến màn hình chính',
      (tester) async {
    final authViewModel = AuthViewModel(MockAuthRepository());
    final cartRepository = _TrackingCartRepository();
    final orderRepository = _TrackingOrderRepository();
    final notificationRepository = _TrackingNotificationRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authViewModel),
          ChangeNotifierProvider(
            create: (_) => CartViewModel(cartRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => NotificationViewModel(notificationRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => OrderViewModel(orderRepository),
          ),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.register,
          routes: {
            AppRoutes.register: (_) => const RegisterScreen(),
            AppRoutes.main: (_) => const Scaffold(
                  key: Key('main_screen'),
                  body: Center(child: Text('Màn hình chính')),
                ),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('name_field')),
      'Nguyễn Văn An',
    );
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'nguyenvanan.integration@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('phone_field')),
      '0912345678',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'KienCare1',
    );
    await tester.enterText(
      find.byKey(const Key('confirm_password_field')),
      'KienCare1',
    );

    final termsCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();

    final registerButton = find.byKey(const Key('register_button'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('main_screen')), findsOneWidget);
    expect(authViewModel.currentUser, isNotNull);
    expect(authViewModel.currentUser!.name, 'Nguyễn Văn An');
    expect(
      authViewModel.currentUser!.email,
      'nguyenvanan.integration@example.com',
    );

    final userId = authViewModel.currentUser!.id;
    expect(cartRepository.loadedUserId, userId);
    expect(orderRepository.loadedUserId, userId);
    expect(notificationRepository.loadedUserId, userId);
  });
}

class _TrackingCartRepository implements CartRepository {
  String? loadedUserId;

  @override
  Future<List<CartItemModel>> getCart(String userId) async {
    loadedUserId = userId;
    return [];
  }

  @override
  Future<void> saveCart(String userId, List<CartItemModel> items) async {}

  @override
  Future<void> clearCart(String userId) async {}
}

class _TrackingOrderRepository implements OrderRepository {
  String? loadedUserId;

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    loadedUserId = userId;
    return [];
  }

  @override
  Future<List<OrderModel>> getAllOrders() async => [];

  @override
  Future<OrderModel?> getOrderById(String orderId) async => null;

  @override
  Future<OrderModel> placeOrder(OrderModel order) async => order;

  @override
  Future<void> cancelOrder(String orderId) async {}

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {}
}

class _TrackingNotificationRepository implements NotificationRepository {
  String? loadedUserId;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    loadedUserId = userId;
    return [];
  }

  @override
  Future<void> addNotification(
    String userId,
    NotificationModel notification,
  ) async {}

  @override
  Future<void> markAllAsRead(String userId) async {}

  @override
  Future<void> markAsRead(String userId, String notificationId) async {}
}
