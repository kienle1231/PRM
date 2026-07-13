# DATABASE DESIGN (SQLITE)

Hệ thống sử dụng bốn cơ sở dữ liệu SQLite cục bộ. Tất cả `user_id` đều dùng
kiểu `TEXT` để lưu trực tiếp Firebase UID. Ngày giờ được lưu dưới dạng chuỗi
ISO 8601.

| Database | Phiên bản | Bảng |
|---|---:|---|
| `kiencare_cart.db` | 2 | `cart_items` |
| `kiencare_orders.db` | 2 | `orders`, `order_items` |
| `kiencare_auth.db` | 2 | `user_profiles` |
| `kiencare_wishlist.db` | 3 | `wishlist` |

## Bảng `cart_items`

Bảng lưu các sản phẩm trong giỏ hàng của từng người dùng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Giải thích |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | ID tự tăng của mỗi dòng sản phẩm trong giỏ hàng. |
| `user_id` | TEXT | NOT NULL; CHECK không rỗng; UNIQUE ghép | Firebase UID của người sở hữu giỏ hàng. |
| `product_id` | TEXT | NOT NULL; CHECK không rỗng; UNIQUE ghép | ID sản phẩm được thêm vào giỏ hàng. |
| `name` | TEXT | NOT NULL | Tên sản phẩm tại thời điểm được thêm vào giỏ. |
| `price` | REAL | NOT NULL; CHECK `price >= 0` | Giá bán của sản phẩm tại thời điểm lưu. |
| `original_price` | REAL | NOT NULL; CHECK `original_price >= 0` | Giá gốc, dùng để tính mức giảm giá hoặc số tiền tiết kiệm. |
| `image_url` | TEXT | NOT NULL | Đường dẫn hình ảnh đại diện của sản phẩm. |
| `quantity` | INTEGER | NOT NULL; DEFAULT 1; CHECK `quantity > 0` | Số lượng sản phẩm trong giỏ hàng. |
| `stock` | INTEGER | NOT NULL; DEFAULT 0; CHECK `stock >= 0` | Số lượng tồn kho được ghi nhận gần nhất. |
| `sort_order` | INTEGER | NOT NULL; DEFAULT 0; CHECK `sort_order >= 0` | Thứ tự hiển thị sản phẩm trong giỏ hàng. |
| `created_at` | TEXT | NOT NULL | Thời điểm dòng giỏ hàng được tạo. |
| `updated_at` | TEXT | NOT NULL | Thời điểm dòng giỏ hàng được cập nhật gần nhất. |

Ràng buộc duy nhất ghép `UNIQUE(user_id, product_id)` bảo đảm một sản phẩm chỉ
có một dòng trong giỏ hàng của mỗi người dùng.

## Bảng `orders`

Bảng lưu thông tin tổng quát của đơn hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Giải thích |
|---|---|---|---|
| `id` | TEXT | NOT NULL; PRIMARY KEY; CHECK không rỗng | Mã định danh duy nhất của đơn hàng. |
| `user_id` | TEXT | NOT NULL; CHECK không rỗng; INDEX | Firebase UID của người đặt hàng. |
| `subtotal` | REAL | NOT NULL; CHECK `subtotal >= 0` | Tổng tiền hàng trước phí vận chuyển. |
| `shipping_fee` | REAL | NOT NULL; DEFAULT 0; CHECK `shipping_fee >= 0` | Phí vận chuyển của đơn hàng. |
| `total` | REAL | NOT NULL; CHECK `total >= 0` | Tổng số tiền người mua phải thanh toán. |
| `status` | TEXT | NOT NULL; DEFAULT `pending`; CHECK theo danh sách | Trạng thái xử lý hiện tại của đơn hàng. |
| `customer_name` | TEXT | NOT NULL | Họ và tên người nhận hàng. |
| `customer_phone` | TEXT | NOT NULL | Số điện thoại liên hệ của người nhận. |
| `shipping_address` | TEXT | NOT NULL | Địa chỉ giao hàng đầy đủ. |
| `note` | TEXT | Cho phép NULL | Ghi chú tùy chọn của khách hàng. |
| `payment_method` | TEXT | NOT NULL; CHECK không rỗng | Phương thức thanh toán, ví dụ COD, Momo hoặc VNPay. |
| `created_at` | TEXT | NOT NULL | Thời điểm đơn hàng được tạo. |
| `updated_at` | TEXT | Cho phép NULL | Thời điểm đơn hàng được cập nhật gần nhất. |

`status` chỉ chấp nhận: `pending`, `paid`, `confirmed`, `shipping`, `completed`,
`delivered` hoặc `cancelled`.

Index `idx_orders_user_id` hỗ trợ truy vấn lịch sử đơn hàng theo người dùng.

## Bảng `order_items`

Bảng lưu các sản phẩm thuộc từng đơn hàng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Giải thích |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | ID tự tăng của dòng chi tiết đơn hàng. |
| `order_id` | TEXT | NOT NULL; FOREIGN KEY; INDEX; UNIQUE ghép | Mã đơn hàng chứa sản phẩm. |
| `product_id` | TEXT | NOT NULL; CHECK không rỗng; UNIQUE ghép | ID sản phẩm được mua. |
| `name` | TEXT | NOT NULL | Tên sản phẩm tại thời điểm đặt hàng. |
| `price` | REAL | NOT NULL; CHECK `price >= 0` | Giá bán tại thời điểm đặt hàng. |
| `original_price` | REAL | NOT NULL; CHECK `original_price >= 0` | Giá gốc của sản phẩm tại thời điểm đặt hàng. |
| `image_url` | TEXT | NOT NULL | Đường dẫn hình ảnh sản phẩm. |
| `quantity` | INTEGER | NOT NULL; DEFAULT 1; CHECK `quantity > 0` | Số lượng sản phẩm được đặt. |
| `stock` | INTEGER | NOT NULL; DEFAULT 0; CHECK `stock >= 0` | Tồn kho được ghi nhận tại thời điểm đặt hàng. |

Khóa ngoại `order_id` tham chiếu `orders(id)` với `ON DELETE CASCADE`. Khóa
ngoại được bật bằng `PRAGMA foreign_keys = ON`, vì vậy khi xóa một đơn hàng,
các dòng chi tiết của đơn hàng đó cũng được xóa.

Ràng buộc `UNIQUE(order_id, product_id)` ngăn một sản phẩm xuất hiện thành
nhiều dòng trong cùng một đơn hàng. Index `idx_order_items_order_id` hỗ trợ
truy vấn danh sách sản phẩm theo đơn hàng.

## Bảng `user_profiles`

Bảng lưu hồ sơ mở rộng của tài khoản Firebase trên thiết bị. Mật khẩu và thông
tin xác thực không được lưu trong SQLite.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Giải thích |
|---|---|---|---|
| `user_id` | TEXT | NOT NULL; PRIMARY KEY; CHECK không rỗng | Firebase UID của người dùng. |
| `name` | TEXT | NOT NULL | Họ và tên người dùng. |
| `email` | TEXT | NOT NULL; UNIQUE; COLLATE NOCASE | Email tài khoản; không phân biệt chữ hoa và chữ thường khi so sánh. |
| `phone` | TEXT | NOT NULL | Số điện thoại người dùng. |
| `avatar` | TEXT | Cho phép NULL | URL ảnh đại diện của người dùng. |
| `role` | TEXT | NOT NULL; DEFAULT `user`; CHECK `user/admin` | Vai trò của tài khoản trong hệ thống. |
| `is_disabled` | INTEGER | NOT NULL; DEFAULT 0; CHECK `0/1` | Trạng thái tài khoản: 0 là hoạt động, 1 là bị vô hiệu hóa. |
| `created_at` | TEXT | NOT NULL | Thời điểm tài khoản được tạo. |
| `profile_json` | TEXT | NOT NULL | Hồ sơ đầy đủ dạng JSON, bao gồm danh sách địa chỉ. |
| `updated_at` | TEXT | NOT NULL | Thời điểm hồ sơ được cập nhật gần nhất. |

## Bảng `wishlist`

Bảng lưu các sản phẩm yêu thích của từng người dùng.

| Tên cột | Kiểu dữ liệu | Ràng buộc | Giải thích |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | ID tự tăng của mỗi dòng sản phẩm yêu thích. |
| `user_id` | TEXT | NOT NULL; CHECK không rỗng; UNIQUE ghép | Firebase UID của người sở hữu danh sách yêu thích. |
| `product_id` | TEXT | NOT NULL; CHECK không rỗng; UNIQUE ghép | ID sản phẩm được thêm vào danh sách yêu thích. |
| `product_name` | TEXT | NOT NULL | Tên sản phẩm dùng để hiển thị. |
| `product_image` | TEXT | NOT NULL | Đường dẫn hình ảnh chính của sản phẩm. |
| `price` | REAL | NOT NULL; CHECK `price >= 0` | Giá sản phẩm tại thời điểm thêm vào danh sách. |
| `rating` | REAL | NOT NULL; DEFAULT 0; CHECK `0 <= rating <= 5` | Điểm đánh giá của sản phẩm theo thang điểm từ 0 đến 5. |
| `created_at` | TEXT | NOT NULL | Thời điểm sản phẩm được thêm vào danh sách yêu thích. |

Ràng buộc `UNIQUE(user_id, product_id)` bảo đảm một sản phẩm chỉ xuất hiện một
lần trong danh sách yêu thích của mỗi người dùng.

## Quan hệ dữ liệu

Quan hệ khóa ngoại vật lý trong SQLite:

```text
orders (1) ─────────── (N) order_items
```

Các bảng `cart_items`, `orders`, `user_profiles` và `wishlist` đều sử dụng cùng
quy ước Firebase UID dạng `TEXT`. Do chúng nằm trong các file database độc lập,
quan hệ với người dùng là quan hệ logic ở tầng ứng dụng, không phải khóa ngoại
vật lý giữa các database.
