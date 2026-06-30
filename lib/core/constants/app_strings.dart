/// Centralized string constants for LAPTOPHUB app (Vietnamese + English keys).
abstract class AppStrings {
  // ── App Info ───────────────────────────────────────────────────────────────
  static const String appName = 'LAPTOPHUB';
  static const String appTagline = 'Công nghệ chính hãng - Giá tốt nhất';
  static const String appVersion = '1.0.0';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String logout = 'Đăng xuất';
  static const String logoutConfirm = 'Bạn có chắc muốn đăng xuất không?';
  static const String forgotPassword = 'Quên mật khẩu';
  static const String resetPassword = 'Đặt lại mật khẩu';
  static const String resetPasswordDesc =
      'Nhập email của bạn và chúng tôi sẽ gửi link đặt lại mật khẩu.';
  static const String sendResetLink = 'Gửi link đặt lại';
  static const String rememberMe = 'Ghi nhớ đăng nhập';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String fullName = 'Họ và tên';
  static const String phone = 'Số điện thoại';
  static const String noAccount = 'Chưa có tài khoản? ';
  static const String signUpNow = 'Đăng ký ngay';
  static const String hasAccount = 'Đã có tài khoản? ';
  static const String signInNow = 'Đăng nhập';
  static const String orContinueWith = 'hoặc';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboarding1Title =
      'Laptop chính hãng – Đồng hành cùng thành công';
  static const String onboarding1Desc =
      'Laptop, Linh kiện, Phụ kiện — tất cả có mặt tại LAPTOPHUB với giá tốt nhất.';
  static const String onboarding2Title = 'Giao hàng siêu nhanh';
  static const String onboarding2Desc =
      'Nhận hàng trong 2-5 tiếng (nội thành) hoặc 1-3 ngày (tỉnh thành khác). Miễn phí ship đơn trên 1999k.';
  static const String onboarding3Title = 'Hỗ trợ 24/7';
  static const String onboarding3Desc =
      'Đội ngũ tư vấn chuyên nghiệp luôn sẵn sàng giúp bạn chọn sản phẩm phù hợp nhất.';
  static const String getStarted = 'Bắt đầu mua sắm';
  static const String next = 'Tiếp theo';
  static const String skip = 'Bỏ qua';

  // ── Navigation ────────────────────────────────────────────────────────────
  static const String navHome = 'Trang chủ';
  static const String navProducts = 'Sản phẩm';
  static const String navCart = 'Giỏ hàng';
  static const String navNotifications = 'Thông báo';
  static const String navProfile = 'Tài khoản';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String featuredProducts = 'Sản phẩm nổi bật';
  static const String hotDeals = '🔥 Flash Sale';
  static const String categories = 'Danh mục';
  static const String viewAll = 'Xem tất cả';
  static const String searchHint = 'Tìm laptop, gaming, phụ kiện...';
  static const String productSearchHint = 'Tìm kiếm chiếc laptop của bạn';

  // ── Products ──────────────────────────────────────────────────────────────
  static const String products = 'Sản phẩm';
  static const String productDetail = 'Chi tiết sản phẩm';
  static const String filter = 'Bộ lọc';
  static const String noProductsFound = 'Không tìm thấy sản phẩm';
  static const String description = 'Mô tả';
  static const String specifications = 'Thông số kỹ thuật';
  static const String relatedProducts = 'Sản phẩm liên quan';
  static const String addToCart = 'Thêm vào giỏ';
  static const String inStock = 'Còn hàng';
  static const String outOfStock = 'Hết hàng';

  // ── Cart ──────────────────────────────────────────────────────────────────
  static const String cart = 'Giỏ hàng';
  static const String cartEmpty = 'Giỏ hàng trống';
  static const String cartEmptyDesc = 'Hãy thêm sản phẩm vào giỏ hàng của bạn';
  static const String shopNow = 'Mua ngay';
  static const String checkout = 'Thanh toán';
  static const String subtotal = 'Tạm tính';
  static const String shipping = 'Phí vận chuyển';
  static const String total = 'Tổng cộng';
  static const String freeShipping = 'Miễn phí';

  // ── Checkout ──────────────────────────────────────────────────────────────
  static const String checkoutTitle = 'Đặt hàng';
  static const String customerInfo = 'Thông tin người nhận';
  static const String shippingAddress = 'Địa chỉ giao hàng';
  static const String paymentMethod = 'Phương thức thanh toán';
  static const String placeOrder = 'Xác nhận đặt hàng';
  static const String cod = 'Thanh toán khi nhận hàng (COD)';
  static const String bankTransfer = 'Chuyển khoản ngân hàng';
  static const String momoPayment = 'Ví MoMo';
  static const String vnpayPayment = 'VNPay';

  // ── Orders ────────────────────────────────────────────────────────────────
  static const String orderHistory = 'Lịch sử đơn hàng';
  static const String myOrders = 'Đơn hàng của tôi';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = 'Thông báo';
  static const String markAllRead = 'Đánh dấu tất cả đã đọc';
  static const String noNotifications = 'Chưa có thông báo nào';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String support = 'Hỗ trợ trực tuyến';
  static const String supportTeam = 'LAPTOPHUB Support';
  static const String chatHint = 'Nhập tin nhắn...';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = 'Tài khoản';
  static const String editProfile = 'Chỉnh sửa hồ sơ';

  // ── Store Location ────────────────────────────────────────────────────────
  static const String storeLocation = 'Cửa hàng';
  static const String storeLocationTitle = 'Hệ thống cửa hàng';

  // ── Common ────────────────────────────────────────────────────────────────
  static const String error = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String yes = 'Có';
  static const String no = 'Không';
  static const String retry = 'Thử lại';
  static const String loading = 'Đang tải...';
  static const String save = 'Lưu';
}
