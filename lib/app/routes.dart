import 'package:flutter/material.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/main_shell.dart';
import '../views/products/product_list_screen.dart';
import '../views/products/product_detail_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/checkout/checkout_screen.dart';
import '../views/checkout/order_confirmation_screen.dart';
import '../views/orders/order_history_screen.dart';
import '../views/notifications/notifications_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/profile/edit_profile_screen.dart';
import '../views/store_location/store_location_screen.dart';

/// Centralized route definitions and named route generator.
abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderHistory = '/orders';
  static const String notifications = '/notifications';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String storeLocation = '/store-location';
}

/// Route generator — creates routes and passes arguments.
Route<dynamic> generateRoute(RouteSettings settings) {
  Widget page;

  switch (settings.name) {
    case AppRoutes.splash:
      page = const SplashScreen();
      break;
    case AppRoutes.onboarding:
      page = const OnboardingScreen();
      break;
    case AppRoutes.login:
      page = const LoginScreen();
      break;
    case AppRoutes.register:
      page = const RegisterScreen();
      break;
    case AppRoutes.forgotPassword:
      page = const ForgotPasswordScreen();
      break;
    case AppRoutes.main:
      page = const MainShell();
      break;
    case AppRoutes.productList:
      page = const ProductListScreen();
      break;
    case AppRoutes.productDetail:
      page = const ProductDetailScreen();
      break;
    case AppRoutes.cart:
      page = const CartScreen();
      break;
    case AppRoutes.checkout:
      page = const CheckoutScreen();
      break;
    case AppRoutes.orderConfirmation:
      page = const OrderConfirmationScreen();
      break;
    case AppRoutes.orderHistory:
      page = const OrderHistoryScreen();
      break;
    case AppRoutes.notifications:
      page = const NotificationsScreen();
      break;
    case AppRoutes.chat:
      page = const ChatScreen();
      break;
    case AppRoutes.profile:
      page = const ProfileScreen();
      break;
    case AppRoutes.editProfile:
      page = const EditProfileScreen();
      break;
    case AppRoutes.storeLocation:
      page = const StoreLocationScreen();
      break;
    default:
      page = const SplashScreen();
  }

  return MaterialPageRoute(
    builder: (_) => page,
    settings: settings,
  );
}
