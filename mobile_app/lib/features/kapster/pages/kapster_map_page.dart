import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared_widgets/bottom_nav_bar.dart';
import '../../../shared_widgets/card_barbershop.dart';
import '../../../shared_widgets/card_kapster.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../core/services/app_state.dart';
import '../../../core/utils/haversine_distance.dart';
import '../../booking/pages/booking_calendar_page.dart';
import '../../home/pages/barbershop_detail_page.dart';

class BarbershopLocation extends Barbershop {
  const BarbershopLocation({
    required super.name,
    required super.distanceKm,
    required super.rating,
    super.imageUrl,
    super.isNew = false,
    super.durationOpen = '',
    required double latitude,
    required double longitude,
  }) : super(latitude: latitude, longitude: longitude);
}

class KapsterLocation extends Kapster {
  final double latitude;
  final double longitude;

  const KapsterLocation({
    required super.nama,
    super.fotoUrl,
    required super.rating,
    super.spesialisasi = const [],
    super.badgeType,
    super.isReady = false,
    super.topRank,
    required this.latitude,
    required this.longitude,
  });
}

class KapsterMapPage extends StatefulWidget {
  const KapsterMapPage({super.key});

  @override
  State<KapsterMapPage> createState() => _KapsterMapPageState();
}

class _KapsterMapPageState extends State<KapsterMapPage> {
  final MapController _mapController = MapController();
  latlong.LatLng? _currentLocation;
  double? _userAccuracy;
  bool _isLoadingLocation = true;
  int _selectedMarkerIdx = -1;
  double? _lastKnownUserLat;
  double? _lastKnownUserLng;
  List<BarbershopLocation> _rekomendasiBarbershop = const [];

  static const latlong.LatLng _semarangCenter = latlong.LatLng(-6.9667, 110.4167);

  List<BarbershopLocation> get _barbershops {
    final userLat = _lastKnownUserLat ?? 0.0;
    final userLng = _lastKnownUserLng ?? 0.0;
    return appState.barbershops
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) {
      final distKm = haversineDistanceKm(userLat, userLng, p.latitude!, p.longitude!);
      return BarbershopLocation(
        name: p.name,
        distanceKm: distKm,
        rating: p.rating,
        imageUrl: p.coverUrl,
        isNew: p.isNew,
        durationOpen: p.hours,
        latitude: p.latitude!,
        longitude: p.longitude!,
      );
    }).toList();
  }

  List<KapsterLocation> get _allKapsters {
    final userLat = _lastKnownUserLat ?? _semarangCenter.latitude;
    final userLng = _lastKnownUserLng ?? _semarangCenter.longitude;
    final List<KapsterLocation> result = [];
    for (final kp in appState.kapsters) {
      final lat = kp.latitude ?? userLat;
      final lng = kp.longitude ?? userLng;
      result.add(KapsterLocation(
        nama: kp.name,
        fotoUrl: kp.photoUrl,
        rating: kp.rating,
        spesialisasi: kp.specialties,
        badgeType: kp.badgeType,
        isReady: kp.isReady,
        topRank: kp.topRank,
        latitude: lat,
        longitude: lng,
      ));
    }
    final Set<String> added = result.map((e) => e.nama).toSet();
    for (final bs in appState.barbershops) {
      final shopLat = bs.latitude ?? userLat;
      final shopLng = bs.longitude ?? userLng;
      for (final bk in bs.kapsters) {
        if (added.contains(bk.name)) continue;
        added.add(bk.name);
        result.add(KapsterLocation(
          nama: bk.name,
          fotoUrl: bk.photoUrl,
          rating: bk.rating,
          spesialisasi: [bk.specialty],
          isReady: bk.isActive,
          latitude: shopLat + (bk.id * 0.0001),
          longitude: shopLng + (bk.id * 0.0001),
        ));
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    appState.addListener(_onAppStateChanged);
    _loadInitialLocation();
  }

  @override
  void dispose() {
    appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
      _applyHaversineSort();
    }
  }

  Future<void> _loadInitialLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = _semarangCenter;
          _isLoadingLocation = false;
          _lastKnownUserLat = _semarangCenter.latitude;
          _lastKnownUserLng = _semarangCenter.longitude;
          appState.updateUserLocation(_semarangCenter.latitude, _semarangCenter.longitude);
          _applyHaversineSort();
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = _semarangCenter;
          _isLoadingLocation = false;
          _lastKnownUserLat = _semarangCenter.latitude;
          _lastKnownUserLng = _semarangCenter.longitude;
          appState.updateUserLocation(_semarangCenter.latitude, _semarangCenter.longitude);
          _applyHaversineSort();
        });
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      final userLatLng = latlong.LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = userLatLng;
        _userAccuracy = pos.accuracy;
        _isLoadingLocation = false;
        _lastKnownUserLat = pos.latitude;
        _lastKnownUserLng = pos.longitude;
        appState.updateUserLocation(pos.latitude, pos.longitude);
        _applyHaversineSort();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _currentLocation != null) {
          _mapController.move(_currentLocation!, 15);
        }
      });
    } catch (_) {
      setState(() {
        _currentLocation = _semarangCenter;
        _isLoadingLocation = false;
        _lastKnownUserLat = _semarangCenter.latitude;
        _lastKnownUserLng = _semarangCenter.longitude;
        appState.updateUserLocation(_semarangCenter.latitude, _semarangCenter.longitude);
        _applyHaversineSort();
      });
    }
  }

  void _applyHaversineSort() {
    if (_lastKnownUserLat == null || _lastKnownUserLng == null) return;
    final shops = _barbershops;
    final sorted = sortByDistanceLatLng<BarbershopLocation>(
      items: shops,
      userLat: _lastKnownUserLat!,
      userLng: _lastKnownUserLng!,
      getLat: (b) => b.latitude ?? _semarangCenter.latitude,
      getLng: (b) => b.longitude ?? _semarangCenter.longitude,
    );
    final List<BarbershopLocation> top3 = [];
    for (int i = 0; i < sorted.length && i < 3; i++) {
      final b = sorted[i];
      final jarakKm = haversineDistanceKm(
        _lastKnownUserLat!,
        _lastKnownUserLng!,
        b.latitude ?? _semarangCenter.latitude,
        b.longitude ?? _semarangCenter.longitude,
      );
      top3.add(BarbershopLocation(
        name: b.name,
        distanceKm: jarakKm,
        rating: b.rating,
        imageUrl: b.imageUrl,
        isNew: b.isNew,
        durationOpen: b.durationOpen,
        latitude: b.latitude ?? _semarangCenter.latitude,
        longitude: b.longitude ?? _semarangCenter.longitude,
      ));
    }
    if (mounted) {
      setState(() {
        _rekomendasiBarbershop = top3;
      });
    }
  }

  List<CircleMarker> _buildUserAccuracyCircle(latlong.LatLng pos) {
    final radius = _userAccuracy != null && _userAccuracy! > 0
        ? _userAccuracy!
        : 50.0;
    return [
      CircleMarker(
        point: pos,
        color: TrimeColors.secondaryBlue.withValues(alpha: 0.18),
        borderColor: TrimeColors.secondaryBlue.withValues(alpha: 0.5),
        borderStrokeWidth: 2,
        radius: radius,
      ),
    ];
  }

  List<Marker> _buildAllMarkers() {
    final markers = <Marker>[];
    final pos = _currentLocation ?? _semarangCenter;

    markers.add(
      Marker(
        point: pos,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.cyan,
            size: 44,
          ),
        ),
      ),
    );

    final shops = _barbershops;
    for (int i = 0; i < shops.length; i++) {
      final b = shops[i];
      final shopLat = b.latitude ?? _semarangCenter.latitude;
      final shopLng = b.longitude ?? _semarangCenter.longitude;
      markers.add(
        Marker(
          point: latlong.LatLng(shopLat, shopLng),
          width: 34,
          height: 34,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMarkerIdx = i);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${b.name} dipilih')),
              );
            },
            child: const Icon(
              Icons.place,
              color: Colors.red,
              size: 34,
              shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
            ),
          ),
        ),
      );
    }

    final kapsters = _allKapsters;
    for (int i = 0; i < kapsters.length; i++) {
      final k = kapsters[i];
      final color =
          k.badgeType == 'exclusive' ? Colors.deepPurple : Colors.blue;
      markers.add(
        Marker(
          point: latlong.LatLng(k.latitude, k.longitude),
          width: 30,
          height: 30,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMarkerIdx = i);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${k.nama} dipilih')),
              );
            },
            child: Icon(
              Icons.place,
              color: color,
              size: 30,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Future<void> _launchDirections(
    double latitude,
    double longitude,
    String label,
  ) async {
    String originParam = '';
    if (_lastKnownUserLat != null && _lastKnownUserLng != null) {
      originParam = 'origin=$_lastKnownUserLat,$_lastKnownUserLng&';
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&${originParam}destination=$latitude,$longitude&destination_place_id=${Uri.encodeComponent(label)}&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  void _navigateToBooking({Barbershop? b, Kapster? k}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BookingCalendarPage(initialBarbershop: b, initialKapster: k),
      ),
    );
  }

  void _navigateBarbershopDetail(Barbershop b) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BarbershopDetailPage(barbershop: b)),
    );
  }

  Widget _emptyHint(String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: TrimeColors.textMuted),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: TrimeColors.textMuted, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: TrimeColors.background,
        appBar: AppBar(
          backgroundColor: TrimeColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Barbershop atau Kapster',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter lokasi & rating')),
                  );
                },
                icon: const Icon(Icons.filter_alt_outlined),
              ),
            ),
          ),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(height: 40, text: 'Kapster'),
              Tab(height: 40, text: 'Barbershop'),
              Tab(height: 40, text: 'Promo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildKapsterMapTab(),
            _buildBarbershopTab(),
            const PlaceholderScreen(
              title: 'Promo Menanti',
              icon: Icons.local_offer_outlined,
              subtitle: 'Diskon dan voucher spesial dari TRIME segera hadir!',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _currentLocation == null
              ? null
              : () {
                  _mapController.move(_currentLocation!, 16);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Menuju lokasi kamu'),
                    ),
                  );
                },
          backgroundColor: TrimeColors.primaryNavy,
          icon: const Icon(Icons.my_location_rounded, color: Colors.white),
          label: Text(
            'Lokasi Saya',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKapsterMapTab() {
    final kapsters = _allKapsters;
    final topKapster = kapsters.isNotEmpty ? kapsters.first : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        _isLoadingLocation || _currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : _buildMapLayer(),
        DraggableScrollableSheet(
          minChildSize: 0.30,
          maxChildSize: 0.72,
          initialChildSize: 0.42,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: TrimeColors.background,
                borderRadius: TrimeSpacing.bottomSheetRadius,
                boxShadow: [
                  BoxShadow(
                    color: TrimeColors.textPrimary.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: TrimeSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TrimeColors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: TrimeSpacing.md),
                    if (topKapster != null)
                      CardKapster(
                        kapster: topKapster,
                        onTap: () => _navigateToBooking(k: topKapster),
                      )
                    else
                      _emptyHint(
                        'Belum ada kapster yang terdaftar di sekitar kamu.',
                        Icons.content_cut,
                      ),
                    if (_selectedMarkerIdx >= 0 &&
                        _selectedMarkerIdx < kapsters.length) ...[
                      const SizedBox(height: TrimeSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              mini: true,
                              label:
                                  'Rute ke ${kapsters[_selectedMarkerIdx].nama}',
                              prefixIcon: Icons.directions,
                              onPressed: () => _launchDirections(
                                kapsters[_selectedMarkerIdx].latitude,
                                kapsters[_selectedMarkerIdx].longitude,
                                kapsters[_selectedMarkerIdx].nama,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: TrimeSpacing.lg),
                    Text(
                      'Rekomendasi terdekat untukmu',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: TrimeSpacing.sm),
                    if (_rekomendasiBarbershop.isEmpty)
                      _emptyHint(
                        'Belum ada rekomendasi barbershop.\n\nLogin sebagai Mitra untuk menambahkan toko dan atur lokasi.',
                        Icons.storefront_outlined,
                      )
                    else
                      SizedBox(
                        height: 360,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _rekomendasiBarbershop.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(width: TrimeSpacing.md),
                          itemBuilder: (context, index) {
                            final b = _rekomendasiBarbershop[index];
                            return SizedBox(
                              width: 220,
                              child: CardBarbershop(
                                barbershop: b,
                                isFavorite:
                                    appState.isFavoriteBarbershop(b.name),
                                onTap: () => _navigateBarbershopDetail(b),
                                onBook: () => _navigateToBooking(b: b),
                                onFavorite: () =>
                                    appState.toggleFavoriteBarbershop(b.name),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: TrimeSpacing.xl),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMapLayer() {
    final userPos = _currentLocation ?? _semarangCenter;
    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userPos,
            initialZoom: 14,
            minZoom: 11,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.trime.app',
              retinaMode: true,
            ),
            CircleLayer(circles: _buildUserAccuracyCircle(userPos)),
            MarkerLayer(markers: _buildAllMarkers()),
          ],
        ),
        _buildMapLegend(),
      ],
    );
  }

  Widget _buildMapLegend() {
    return Positioned(
      left: 12,
      bottom: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendDot(Colors.red),
            const SizedBox(width: 4),
            Text(
              'Barber',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _legendDot(Colors.blue),
            const SizedBox(width: 4),
            Text(
              'Kapster',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: TrimeColors.primaryNavy,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Kamu',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
      ),
    );
  }

  Widget _buildBarbershopTab() {
    final shops = _barbershops;
    if (shops.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [
          _emptyHint(
            'Belum ada Barbershop yang terdaftar.\n\nSilakan login sebagai Mitra untuk menambahkan toko barbershop Anda beserta lokasi koordinatnya.',
            Icons.storefront_outlined,
          ),
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: TrimeSpacing.md,
      mainAxisSpacing: TrimeSpacing.md,
      childAspectRatio: 0.62,
      padding: TrimeSpacing.screenPadding,
      children: shops.map((b) {
        return CardBarbershop(
          barbershop: b,
          isFavorite: appState.isFavoriteBarbershop(b.name),
          onTap: () => _navigateBarbershopDetail(b),
          onBook: () => _navigateToBooking(b: b),
          onFavorite: () => appState.toggleFavoriteBarbershop(b.name),
        );
      }).toList(growable: false),
    );
  }
}
