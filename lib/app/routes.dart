import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
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
import '../views/checkout/payment_screen.dart';
import '../views/checkout/order_confirmation_screen.dart';
import '../views/address/address_selection_screen.dart';
import '../views/address/address_form_screen.dart';
import '../views/orders/order_history_screen.dart';
import '../views/orders/order_detail_screen.dart';
import '../views/admin/admin_orders_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/admin_product_list_screen.dart';
import '../views/admin/admin_product_form_screen.dart';
import '../views/admin/admin_revenue_screen.dart';
import '../views/admin/admin_user_list_screen.dart';
import '../views/admin/admin_chat_list_screen.dart';
import '../views/admin/admin_chat_detail_screen.dart';
import '../views/notifications/notifications_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/profile/edit_profile_screen.dart';
import '../views/store_location/store_location_screen.dart';
import '../views/wishlist/wishlist_screen.dart';

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
  static const String payment = '/payment';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderHistory = '/orders';
  static const String adminOrders = '/admin-orders';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminProducts = '/admin-products';
  static const String adminProductForm = '/admin-product-form';
  static const String adminRevenue = '/admin-revenue';
  static const String adminUsers = '/admin-users';
  static const String adminChats = '/admin-chats';
  static const String adminChatDetail = '/admin-chat-detail';
  static const String notifications = '/notifications';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String storeLocation = '/store-location';
  static const String wishlist = '/wishlist';
  static const String addressSelection = '/address-selection';
  static const String addressForm = '/address-form';
  static const String orderDetail = '/order-detail';
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
      final initialIndex = settings.arguments as int? ?? 0;
      page = MainShell(initialIndex: initialIndex);
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
      final items = settings.arguments as List<dynamic>?;
      final singleItems = items?.cast<CartItemModel>();
      page = CheckoutScreen(singleItems: singleItems);
      break;
    case AppRoutes.payment:
      page = const PaymentScreen();
      break;
    case AppRoutes.orderConfirmation:
      page = const OrderConfirmationScreen();
      break;
    case AppRoutes.addressSelection:
      page = const AddressSelectionScreen();
      break;
    case AppRoutes.addressForm:
      final address = settings.arguments as AddressModel?;
      page = AddressFormScreen(address: address);
      break;
    case AppRoutes.orderHistory:
      page = const OrderHistoryScreen();
      break;
    case AppRoutes.orderDetail:
      final order = settings.arguments as OrderModel;
      page = OrderDetailScreen(order: order);
      break;
    case AppRoutes.adminOrders:
      page = const AdminOrdersScreen();
      break;
    case AppRoutes.adminDashboard:
      page = const AdminDashboardScreen();
      break;
    case AppRoutes.adminProducts:
      page = const AdminProductListScreen();
      break;
    case AppRoutes.adminProductForm:
      final product = settings.arguments as ProductModel?;
      page = AdminProductFormScreen(product: product);
      break;
    case AppRoutes.adminRevenue:
      page = const AdminRevenueScreen();
      break;
    case AppRoutes.adminUsers:
      page = const AdminUserListScreen();
      break;
    case AppRoutes.adminChats:
      page = const AdminChatListScreen();
      break;
    case AppRoutes.adminChatDetail:
      final userId = settings.arguments as String;
      page = AdminChatDetailScreen(userId: userId);
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
    case AppRoutes.wishlist:
      page = const WishlistScreen();
      break;
    default:
      page = const SplashScreen();
  }

  return MaterialPageRoute(
    builder: (_) => page,
    settings: settings,
  );
}
