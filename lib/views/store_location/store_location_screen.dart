import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// KienCare store location data model.
class _StoreLocation {
  final String name;
  final String address;
  final String phone;
  final String hours;
  final double lat;
  final double lng;
  final bool isMainBranch;

  const _StoreLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.lat,
    required this.lng,
    this.isMainBranch = false,
  });
}

/// Store location screen — shows KienCare locations with map and navigation.
class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  int _selectedIndex = 0;

  static const List<_StoreLocation> _locations = [
    _StoreLocation(
      name: 'KienCare - Lê Lợi (Chi nhánh chính)',
      address: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      phone: '028 1234 5678',
      hours: 'Thứ 2 - Chủ nhật: 8:00 - 21:00',
      lat: 10.7769,
      lng: 106.7009,
      isMainBranch: true,
    ),
    _StoreLocation(
      name: 'KienCare - Nguyễn Văn Cừ',
      address: '456 Nguyễn Văn Cừ, Phường 1, Quận 5, TP. Hồ Chí Minh',
      phone: '028 8765 4321',
      hours: 'Thứ 2 - Thứ 7: 8:30 - 20:30',
      lat: 10.7550,
      lng: 106.6840,
    ),
    _StoreLocation(
      name: 'KienCare - Cầu Giấy (Hà Nội)',
      address: '789 Cầu Giấy, Phường Dịch Vọng, Quận Cầu Giấy, Hà Nội',
      phone: '024 3333 4444',
      hours: 'Thứ 2 - Chủ nhật: 8:00 - 21:00',
      lat: 21.0285,
      lng: 105.7922,
    ),
    _StoreLocation(
      name: 'KienCare - Hải Phòng',
      address: '321 Lê Lợi, Quận Ngô Quyền, Hải Phòng',
      phone: '0225 1111 2222',
      hours: 'Thứ 2 - Chủ nhật: 9:00 - 20:00',
      lat: 20.8449,
      lng: 106.6881,
    ),
  ];

  Future<void> _openNavigation(_StoreLocation location) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${location.lat},${location.lng}&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở Google Maps')),
        );
      }
    }
  }

  Future<void> _callStore(_StoreLocation location) async {
    final url = Uri.parse('tel:${location.phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storeLocationTitle),
      ),
      body: Column(
        children: [
          // Map placeholder (requires Google Maps setup)
          _buildMapPlaceholder(),

          // Store list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _locations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _StoreCard(
                location: _locations[i],
                isSelected: _selectedIndex == i,
                isDark: isDark,
                onTap: () => setState(() => _selectedIndex = i),
                onNavigate: () => _openNavigation(_locations[i]),
                onCall: () => _callStore(_locations[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // TODO: Replace with Google Maps widget after configuring API key
    // GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: LatLng(_locations[_selectedIndex].lat, _locations[_selectedIndex].lng),
    //     zoom: 14,
    //   ),
    //   markers: _locations.map((l) => Marker(
    //     markerId: MarkerId(l.name),
    //     position: LatLng(l.lat, l.lng),
    //     infoWindow: InfoWindow(title: l.name, snippet: l.address),
    //   )).toSet(),
    // )

    return Container(
      height: 200,
      color: AppColors.primarySurface,
      child: Stack(
        children: [
          // Simulated map grid
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _MapGridPainter(),
          ),

          // Center pin
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.secondary, size: 32),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    '📍 ${_storeCount} cửa hàng KienCare',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Setup hint
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cần cấu hình Google Maps API Key',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _storeCount = 4;
}

class _StoreCard extends StatelessWidget {
  final _StoreLocation location;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onCall;

  const _StoreCard({
    required this.location,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.onNavigate,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store name + main badge
            Row(
              children: [
                Icon(
                  Icons.store_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                ),
                if (location.isMainBranch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chính',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location.address,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Hours
            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(location.hours,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Gọi điện'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.directions_rounded, size: 16),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a simple street-map-like grid background.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D8E8)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Thicker roads
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 8;

    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
