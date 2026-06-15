import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class _BannerItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Color overlayColor;

  const _BannerItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.overlayColor,
  });
}

/// Auto-scrolling promotional banner carousel.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  static const List<_BannerItem> _banners = [
    _BannerItem(
      imageUrl: AppImages.banner1,
      title: 'Sale 10.10',
      subtitle: 'Giảm đến 50% tất cả laptop',
      overlayColor: AppColors.primary,
    ),
    _BannerItem(
      imageUrl: AppImages.banner2,
      title: 'Gaming Gear HOT',
      subtitle: 'Bàn phím, chuột, tai nghe giảm sốc',
      overlayColor: AppColors.secondary,
    ),
    _BannerItem(
      imageUrl: AppImages.banner3,
      title: 'Laptop Mới Về',
      subtitle: 'MacBook, ASUS ROG, Dell XPS',
      overlayColor: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: _banners.length,
          itemBuilder: (_, i, __) => _buildBannerCard(_banners[i]),
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.92,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _current,
          count: _banners.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.borderLight,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
            spacing: 4,
          ),
          onDotClicked: (i) => _controller.animateToPage(i),
        ),
      ],
    );
  }

  Widget _buildBannerCard(_BannerItem banner) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: banner.overlayColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: banner.overlayColor),
              errorWidget: (_, __, ___) => Container(
                color: banner.overlayColor,
                child: Center(
                  child: Text(banner.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    banner.overlayColor.withValues(alpha: 0.85),
                    banner.overlayColor.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Text content
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Mua ngay',
                      style: TextStyle(
                        color: banner.overlayColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
