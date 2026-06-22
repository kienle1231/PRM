import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// LAPTOPHUB store location data model.
class _StoreLocation {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final double lat;
  final double lng;
  final bool isMainBranch;

  const _StoreLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.lat,
    required this.lng,
    this.isMainBranch = false,
  });

  LatLng get latLng => LatLng(lat, lng);
}

/// Store location screen — shows LAPTOPHUB locations with Google Map and navigation.
class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer();
  int _selectedIndex = 0;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const List<_StoreLocation> _locations = [
    _StoreLocation(
      id: 'store_1',
      name: 'LAPTOPHUB - Lê Lợi (Chi nhánh chính)',
      address: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      phone: '028 1234 5678',
      hours: 'Thứ 2 - Chủ nhật: 8:00 - 21:00',
      lat: 10.7769,
      lng: 106.7009,
      isMainBranch: true,
    ),
    _StoreLocation(
      id: 'store_2',
      name: 'LAPTOPHUB - Nguyễn Văn Cừ',
      address: '456 Nguyễn Văn Cừ, Phường 1, Quận 5, TP. Hồ Chí Minh',
      phone: '028 8765 4321',
      hours: 'Thứ 2 - Thứ 7: 8:30 - 20:30',
      lat: 10.7550,
      lng: 106.6840,
    ),
    _StoreLocation(
      id: 'store_3',
      name: 'LAPTOPHUB - Cầu Giấy (Hà Nội)',
      address: '789 Cầu Giấy, Phường Dịch Vọng, Quận Cầu Giấy, Hà Nội',
      phone: '024 3333 4444',
      hours: 'Thứ 2 - Chủ nhật: 8:00 - 21:00',
      lat: 21.0285,
      lng: 105.7922,
    ),
    _StoreLocation(
      id: 'store_4',
      name: 'LAPTOPHUB - Hải Phòng',
      address: '321 Lê Lợi, Quận Ngô Quyền, Hải Phòng',
      phone: '0225 1111 2222',
      hours: 'Thứ 2 - Chủ nhật: 9:00 - 20:00',
      lat: 20.8449,
      lng: 106.6881,
    ),
  ];

  Set<Marker> get _markers {
    final markers = <Marker>{};
    for (int i = 0; i < _locations.length; i++) {
      final loc = _locations[i];
      markers.add(
        Marker(
          markerId: MarkerId(loc.id),
          position: loc.latLng,
          infoWindow: InfoWindow(
            title: loc.name,
            snippet: loc.address,
          ),
          icon: i == _selectedIndex
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () => setState(() => _selectedIndex = i),
        ),
      );
    }

    // Add user location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Vui lòng bật dịch vụ định vị');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Quyền truy cập vị trí bị từ chối');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Hãy cấp quyền vị trí trong cài đặt');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() => _currentPosition = position);

      final ctrl = await _mapController.future;
      await ctrl.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          ),
        ),
      );
    } catch (e) {
      _showSnack('Không thể lấy vị trí: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _animateTo(_StoreLocation location) async {
    setState(() => _selectedIndex = _locations.indexOf(location));
    final ctrl = await _mapController.future;
    await ctrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location.latLng, zoom: 15),
      ),
    );
  }

  Future<void> _openNavigation(_StoreLocation location) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${location.lat},${location.lng}&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Không thể mở Google Maps');
    }
  }

  Future<void> _callStore(_StoreLocation location) async {
    final url = Uri.parse('tel:${location.phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storeLocationTitle),
        actions: [
          // My location button in AppBar
          IconButton(
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location_rounded),
            tooltip: 'Vị trí của tôi',
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Google Map ──────────────────────────────────────────────────────
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _locations[0].latLng,
                    zoom: 12,
                  ),
                  onMapCreated: (ctrl) => _mapController.complete(ctrl),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                ),

                // Store count badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_locations.length} cửa hàng',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // My location FAB
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'myLocation',
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: _isLoadingLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded,
                            color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // ── Store list ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.secondary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Chọn chi nhánh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_locations.length} chi nhánh',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _StoreCard(
                  location: _locations[i],
                  isSelected: _selectedIndex == i,
                  isDark: isDark,
                  onTap: () => _animateTo(_locations[i]),
                  onNavigate: () => _openNavigation(_locations[i]),
                  onCall: () => _callStore(_locations[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Store Card ─────────────────────────────────────────────────────────────────
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store name + badges
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    location.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                ),
                if (location.isMainBranch)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            const SizedBox(height: 10),

            // Address
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: location.address,
            ),
            const SizedBox(height: 4),

            // Hours
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: location.hours,
            ),
            const SizedBox(height: 4),

            // Phone
            _InfoRow(
              icon: Icons.phone_outlined,
              text: location.phone,
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone_rounded, size: 15),
                    label: const Text('Gọi điện'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      minimumSize: Size.zero,
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.directions_rounded, size: 15),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
