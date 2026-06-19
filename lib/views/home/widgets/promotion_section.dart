import 'package:flutter/material.dart';
import '../../../models/promotion_model.dart';
import 'mock_promotions.dart';

/// Section hiển thị các chương trình khuyến mãi đang diễn ra trên trang chủ.
/// Cuộn ngang, mỗi thẻ có ảnh minh họa (gradient + emoji), badge loại, countdown, highlights.
class PromotionSection extends StatelessWidget {
  const PromotionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final promotions = MockPromotions.active;
    if (promotions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Text(
                '🎉 Khuyến Mãi Nổi Bật',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${promotions.length} ưu đãi',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF86868B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable Cards ─────────────────────────────────────────────────
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: promotions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _PromotionCard(
              promotion: promotions[i],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Promotion Card ──────────────────────────────────────────────────────────

class _PromotionCard extends StatelessWidget {
  final PromotionModel promotion;

  const _PromotionCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        promotion.route,
        arguments: promotion.routeArgs,
      ),
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: promotion.primaryColor.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // ── Background gradient ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      promotion.primaryColor,
                      promotion.primaryColor.withValues(alpha: 0.75),
                      promotion.accentColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // ── Background circle decoration ───────────────────────────
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              // ── Big Emoji illustration ─────────────────────────────────
              Positioned(
                right: 10,
                top: 16,
                child: Text(
                  promotion.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag badge
                    _TagBadge(tag: promotion.tag, color: promotion.accentColor),
                    const SizedBox(height: 8),

                    // Discount / label
                    if (promotion.discountPercent > 0)
                      Text(
                        'Giảm ${promotion.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      )
                    else if (promotion.discountLabel != null)
                      Text(
                        promotion.discountLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Title
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      promotion.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Countdown + Highlights
                    _CountdownRow(promotion: promotion),
                  ],
                ),
              ),

              // ── Ripple ink ────────────────────────────────────────────
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pushNamed(
                      context,
                      promotion.route,
                      arguments: promotion.routeArgs,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tag Badge ───────────────────────────────────────────────────────────────

class _TagBadge extends StatelessWidget {
  final String tag;
  final Color color;

  const _TagBadge({required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Countdown Row ────────────────────────────────────────────────────────────

class _CountdownRow extends StatelessWidget {
  final PromotionModel promotion;

  const _CountdownRow({required this.promotion});

  String get _timeLabel {
    final days = promotion.daysLeft;
    if (days <= 0) {
      final hours = promotion.hoursLeft;
      if (hours <= 0) return 'Kết thúc hôm nay';
      return 'Còn $hours giờ';
    } else if (days == 1) {
      return 'Còn 1 ngày';
    } else if (days <= 7) {
      return 'Còn $days ngày';
    } else {
      final endDate = promotion.endDate;
      return 'Đến ${endDate.day}/${endDate.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Colors.white70, size: 11),
              const SizedBox(width: 4),
              Text(
                _timeLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'Xem →',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
