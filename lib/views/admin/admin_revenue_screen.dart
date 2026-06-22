import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../viewmodels/order_viewmodel.dart';

enum _Period { today, week, month, all }

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _Period _period = _Period.week;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _period = _Period.values[_tabController.index];
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchAllOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    switch (_period) {
      case _Period.today:
        return orders.where((o) {
          final d = o.createdAt;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
      case _Period.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((o) => o.createdAt.isAfter(weekAgo)).toList();
      case _Period.month:
        return orders
            .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
            .toList();
      case _Period.all:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Thống kê doanh thu'),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Hôm nay'),
            Tab(text: 'Tuần này'),
            Tab(text: 'Tháng này'),
            Tab(text: 'Tất cả'),
          ],
        ),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.allOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filterOrders(vm.allOrders);
          final completedOrders = filtered
              .where((o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.delivered)
              .toList();

          final totalRevenue = completedOrders.fold<double>(0, (s, o) => s + o.total);
          final avgOrder = completedOrders.isEmpty ? 0.0 : totalRevenue / completedOrders.length;

          return RefreshIndicator(
            onRefresh: () => vm.fetchAllOrders(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Summary Cards ───────────────────────────────────────────
                _buildSummaryRow(
                  revenue: totalRevenue,
                  totalOrders: filtered.length,
                  avgOrder: avgOrder,
                ),

                const SizedBox(height: 20),

                // ── Bar Chart ───────────────────────────────────────────────
                _RevenueChart(orders: vm.allOrders),

                const SizedBox(height: 20),

                // ── Order Status Breakdown ───────────────────────────────────
                _OrderStatusBreakdown(orders: filtered),

                const SizedBox(height: 20),

                // ── Top Products ────────────────────────────────────────────
                _TopProductsCard(orders: completedOrders),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow({
    required double revenue,
    required int totalOrders,
    required double avgOrder,
  }) {
    return Column(
      children: [
        // Big revenue card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _periodLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppFormatters.vnd(revenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Doanh thu (đơn hoàn thành)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.shopping_cart_rounded,
                iconColor: const Color(0xFF007AFF),
                bgColor: const Color(0xFFEFF5FF),
                value: totalOrders.toString(),
                label: 'Tổng đơn hàng',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.calculate_rounded,
                iconColor: const Color(0xFF34C759),
                bgColor: const Color(0xFFEFFFF4),
                value: AppFormatters.vnd(avgOrder),
                label: 'Trung bình / đơn',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String get _periodLabel {
    switch (_period) {
      case _Period.today:
        return 'Hôm nay';
      case _Period.week:
        return '7 ngày gần nhất';
      case _Period.month:
        return 'Tháng này';
      case _Period.all:
        return 'Tất cả thời gian';
    }
  }
}

// ── Revenue Bar Chart ─────────────────────────────────────────────────────────
class _RevenueChart extends StatelessWidget {
  final List<OrderModel> orders;
  const _RevenueChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Build daily revenue for last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final Map<String, double> dailyRevenue = {};
    for (final day in days) {
      final key = DateFormat('dd/MM').format(day);
      dailyRevenue[key] = 0;
    }

    for (final order in orders) {
      if (order.status == OrderStatus.completed ||
          order.status == OrderStatus.delivered) {
        final key = DateFormat('dd/MM').format(order.createdAt);
        if (dailyRevenue.containsKey(key)) {
          dailyRevenue[key] = (dailyRevenue[key] ?? 0) + order.total;
        }
      }
    }

    final maxVal = dailyRevenue.values.fold<double>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu 7 ngày gần nhất',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chỉ tính đơn hoàn thành',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _BarChartPainter(
                data: dailyRevenue,
                maxVal: maxVal == 0 ? 1 : maxVal,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyRevenue.entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 150),
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double maxVal;

  _BarChartPainter({required this.data, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    const chartHeight = 150.0;
    final barWidth = (size.width / data.length) - 8;
    final entries = data.entries.toList();

    final gradientPaint = Paint()..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight / 4 * i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < entries.length; i++) {
      final val = entries[i].value;
      final ratio = val / maxVal;
      final barH = ratio * chartHeight;

      final x = i * (size.width / entries.length) + 4;
      final y = chartHeight - barH;

      // Gradient bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        const Radius.circular(6),
      );

      gradientPaint.shader = LinearGradient(
        colors: val > 0
            ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
            : [const Color(0xFFEEEEEE), const Color(0xFFDDDDDD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x, y, barWidth, barH));

      canvas.drawRRect(rect, gradientPaint);

      // Value label on top of bar
      if (val > 0) {
        final formatted = val >= 1000000
            ? '${(val / 1000000).toStringAsFixed(0)}M'
            : '${val.toStringAsFixed(0)}';
        final tp = TextPainter(
          text: TextSpan(
            text: formatted,
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(x + barWidth / 2 - tp.width / 2, y - tp.height - 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Order Status Breakdown ────────────────────────────────────────────────────
class _OrderStatusBreakdown extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderStatusBreakdown({required this.orders});

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.values;
    final total = orders.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân tích đơn hàng theo trạng thái',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Center(
              child: Text('Không có đơn hàng nào',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...statuses.map((s) {
              final count = orders.where((o) => o.status == s).length;
              final ratio = total > 0 ? count / total : 0.0;
              return _StatusProgressRow(
                status: s,
                count: count,
                ratio: ratio,
              );
            }),
        ],
      ),
    );
  }
}

class _StatusProgressRow extends StatelessWidget {
  final OrderStatus status;
  final int count;
  final double ratio;

  const _StatusProgressRow({
    required this.status,
    required this.count,
    required this.ratio,
  });

  Color get _color {
    switch (status) {
      case OrderStatus.completed:
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.shipping:
        return AppColors.info;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.paid:
        return AppColors.accent;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(status.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              status.label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppColors.primarySurface,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              count.toString(),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Products Card ─────────────────────────────────────────────────────────
class _TopProductsCard extends StatelessWidget {
  final List<OrderModel> orders;
  const _TopProductsCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Aggregate product sales from completed orders
    final Map<String, Map<String, dynamic>> productMap = {};
    for (final order in orders) {
      for (final item in order.items) {
        final id = item.productId;
        if (productMap.containsKey(id)) {
          productMap[id]!['qty'] += item.quantity;
          productMap[id]!['revenue'] += item.price * item.quantity;
        } else {
          productMap[id] = {
            'name': item.name,
            'imageUrl': item.imageUrl,
            'qty': item.quantity,
            'revenue': item.price * item.quantity,
          };
        }
      }
    }

    final sorted = productMap.entries.toList()
      ..sort((a, b) => (b.value['qty'] as int).compareTo(a.value['qty'] as int));
    final top5 = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Top sản phẩm bán chạy',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Từ đơn hàng đã hoàn thành',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (top5.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Chưa có đơn hàng hoàn thành',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...top5.asMap().entries.map((e) {
              final rank = e.key + 1;
              final data = e.value.value;
              return _TopProductRow(
                rank: rank,
                name: data['name'] as String,
                imageUrl: data['imageUrl'] as String?,
                qty: data['qty'] as int,
                revenue: (data['revenue'] as num).toDouble(),
              );
            }),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final String name;
  final String? imageUrl;
  final int qty;
  final double revenue;

  const _TopProductRow({
    required this.rank,
    required this.name,
    required this.imageUrl,
    required this.qty,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : AppColors.textHint;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank == 1
            ? const Color(0xFFFFFBE6)
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1
              ? const Color(0xFFFFD700).withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(imageUrl!, width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.primarySurface,
                        child: const Icon(Icons.laptop_rounded,
                            size: 20, color: AppColors.textHint)))
                : Container(
                    width: 40,
                    height: 40,
                    color: AppColors.primarySurface,
                    child: const Icon(Icons.laptop_rounded,
                        size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppFormatters.vnd(revenue),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'đã bán',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Card ─────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
