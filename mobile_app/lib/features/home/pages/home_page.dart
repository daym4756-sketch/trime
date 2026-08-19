import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../../shared_widgets/trime_logo.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/card_barbershop.dart';
import '../../../shared_widgets/card_kapster.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/app_state.dart';
import '../../../core/utils/haversine_distance.dart';
import '../../rambutku/pages/ai_result_page.dart';
import '../../booking/pages/booking_calendar_page.dart';
import '../../kapster/pages/kapster_map_page.dart';
import 'barbershop_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _selectedFilters = {'📍 Area Terdekat'};
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_onAppStateChanged);
    _initDeviceLocation();
  }

  Future<void> _initDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await appState.updateLastKnownLocation(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Error getting GPS location on home page: $e');
    }
  }

  @override
  void dispose() {
    appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleAiAnalysis() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _aiService.analyzeFaceShape(File(photo.path));

      if (!mounted) return;

      if (result['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiResultPage(
              faceShape: result['face_shape'] ?? 'oval',
              imagePath: photo.path,
              detailedResult: result,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error'] ?? 'Gagal menganalisis'}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  List<Barbershop> get _allBarbershops {
    final userLat = appState.lastKnownLat ?? 0.0;
    final userLng = appState.lastKnownLng ?? 0.0;
    return appState.barbershops.map((p) {
      double distKm = 0.0;
      if (p.latitude != null && p.longitude != null) {
        distKm = haversineDistanceKm(userLat, userLng, p.latitude!, p.longitude!);
      }
      return Barbershop(
        name: p.name,
        distanceKm: distKm,
        rating: p.rating,
        imageUrl: p.coverUrl,
        isNew: p.isNew,
        durationOpen: p.hours,
        latitude: p.latitude,
        longitude: p.longitude,
      );
    }).toList();
  }

  List<Kapster> get _allKapsters {
    final List<Kapster> result = [];
    for (final kp in appState.kapsters) {
      result.add(Kapster(
        nama: kp.name,
        fotoUrl: kp.photoUrl,
        rating: kp.rating,
        spesialisasi: kp.specialties,
        badgeType: kp.badgeType,
        isReady: kp.isReady,
        topRank: kp.topRank,
      ));
    }
    final Set<String> addedNames = result.map((e) => e.nama).toSet();
    for (final bs in appState.barbershops) {
      for (final bk in bs.kapsters) {
        if (!addedNames.contains(bk.name)) {
          addedNames.add(bk.name);
          result.add(Kapster(
            nama: bk.name,
            fotoUrl: bk.photoUrl,
            rating: bk.rating,
            spesialisasi: [bk.specialty],
            isReady: bk.isActive,
          ));
        }
      }
    }
    return result;
  }

  void _navigateBooking({Barbershop? b, Kapster? k}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingCalendarPage(initialBarbershop: b, initialKapster: k),
      ),
    );
  }

  Future<void> _launchWhatsApp(String name, [String? jenis]) async {
    final msg = 'Halo $name, saya ingin bertanya tentang ${jenis ?? 'layanan booking'}';
    final uri = Uri.parse(
      'https://wa.me/6281234567890?text=${Uri.encodeComponent(msg)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  void _navigateMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KapsterMapPage()),
    );
  }

  void _navigateBarbershopDetail(Barbershop b) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BarbershopDetailPage(barbershop: b)),
    );
  }

  List<Barbershop> get _sortedBarbershops {
    final copy = List<Barbershop>.from(_allBarbershops);
    final active = _selectedFilters.isNotEmpty ? _selectedFilters.first : '';
    if (active.contains('Rating')) {
      copy.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      copy.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return copy;
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
          Icon(icon, size: 64, color: TrimeColors.textMuted),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: TrimeColors.textMuted, fontSize: 13, height: 1.5)),
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
          title: const TrimeLogo(),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pencarian dibuka')),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: _navigateMap,
              tooltip: 'Lihat Map',
              icon: const Icon(Icons.map_outlined),
            ),
            const SizedBox(width: TrimeSpacing.sm),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(128),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TrimeSpacing.md,
                  ),
                  child: TabBar(
                    isScrollable: false,
                    tabs: [
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.store, size: 14),
                            SizedBox(width: 4),
                            Text('Barberku'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.content_cut, size: 14),
                            SizedBox(width: 4),
                            Text('Kapsterku'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.face, size: 14),
                            SizedBox(width: 4),
                            Text('Rambutku'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TrimeSpacing.lg,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('📍 Area Terdekat'),
                          const SizedBox(width: TrimeSpacing.sm),
                          _buildFilterChip('⭐ Rating Terbaik'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildBarberkuTab(),
                  _buildKapsterkuTab(),
                  _buildRambutkuTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilters.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilters
            ..clear()
            ..add(label);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            content: Text('Filter: $label'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildBarberkuTab() {
    final list = _sortedBarbershops;
    if (list.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [
          _emptyHint(
            'Belum ada Barbershop yang terdaftar.\n\nSilakan login sebagai Mitra untuk menambahkan toko barbershop Anda.',
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
      children: list.map((b) {
        return CardBarbershop(
          barbershop: b,
          isFavorite: appState.isFavoriteBarbershop(b.name),
          onTap: () => _navigateBarbershopDetail(b),
          onBook: () => _navigateBooking(b: b),
          onFavorite: () {
            final added = !appState.isFavoriteBarbershop(b.name);
            appState.toggleFavoriteBarbershop(b.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                backgroundColor: added ? TrimeColors.dangerRed : TrimeColors.textSecondary,
                content: Text(added ? '💖 ${b.name} ditambahkan ke favorit' : '${b.name} dihapus dari favorit'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildKapsterkuTab() {
    final list = _allKapsters;
    if (list.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [
          _emptyHint(
            'Belum ada Kapster yang tersedia.\n\nSilakan login sebagai Kapster untuk mengaktifkan profil Anda, atau Mitra dapat menambahkan kapster internal di dashboard.',
            Icons.content_cut,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: TrimeSpacing.screenPadding,
      itemCount: list.length,
      separatorBuilder: (context, _) => const SizedBox(height: TrimeSpacing.md),
      itemBuilder: (context, index) {
        final k = list[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardKapster(
              kapster: k,
              isFavorite: appState.isFavoriteKapster(k.nama),
              onFavorite: () {
                final added = !appState.isFavoriteKapster(k.nama);
                appState.toggleFavoriteKapster(k.nama);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    backgroundColor: added ? TrimeColors.dangerRed : TrimeColors.textSecondary,
                    content: Text(added ? '💖 ${k.nama} ditambahkan ke favorit' : '${k.nama} dihapus dari favorit'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => _buildKapsterBottomSheet(k),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildKapsterBottomSheet(Kapster k) {
    return Container(
      decoration: const BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.bottomSheetRadius,
      ),
      padding: const EdgeInsets.fromLTRB(
        TrimeSpacing.lg,
        TrimeSpacing.sm,
        TrimeSpacing.lg,
        TrimeSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: TrimeSpacing.md),
                decoration: BoxDecoration(
                  color: TrimeColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            CardKapster(kapster: k),
            const SizedBox(height: TrimeSpacing.md),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    mini: true,
                    label: '💈 Booking',
                    prefixIcon: Icons.event_available,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateBooking(k: k);
                    },
                  ),
                ),
                const SizedBox(width: TrimeSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    mini: true,
                    label: '💬 Chat',
                    prefixIcon: Icons.chat,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _launchWhatsApp(k.nama, 'jadwal potong rambut');
                    },
                  ),
                ),
                const SizedBox(width: TrimeSpacing.sm),
                SizedBox(
                  height: 34,
                  child: IconButton.filled(
                    onPressed: () {
                      final added = !appState.isFavoriteKapster(k.nama);
                      appState.toggleFavoriteKapster(k.nama);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              added ? TrimeColors.dangerRed : TrimeColors.textSecondary,
                          content: Text(
                              added ? '💖 ${k.nama} difavoritkan' : '${k.nama} dihapus favorit'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: appState.isFavoriteKapster(k.nama)
                          ? TrimeColors.dangerRed
                          : TrimeColors.surfaceAlt,
                      foregroundColor: appState.isFavoriteKapster(k.nama)
                          ? Colors.white
                          : TrimeColors.textSecondary,
                    ),
                    icon: Icon(
                      appState.isFavoriteKapster(k.nama)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
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

  Widget _buildRambutkuTab() {
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        _buildAiCard(),
        const SizedBox(height: TrimeSpacing.xl),
        const SizedBox(height: TrimeSpacing.xxl),
      ],
    );
  }

  Widget _buildAiCard() {
    return Container(
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusLg,
      ),
      padding: const EdgeInsets.all(TrimeSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 28,
            color: TrimeColors.secondaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis AI untuk Rambutmu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: TrimeColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pelajari model rambut terbaik wajahmu via AI simulasi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TrimeColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                _isAnalyzing
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                        mini: true,
                        label: '📷 Ambil Foto',
                        prefixIcon: Icons.photo_camera,
                        onPressed: _handleAiAnalysis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
