import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared_widgets/card_barbershop.dart';
import '../../../shared_widgets/card_kapster.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/rating_stars.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../core/services/app_state.dart';
import '../../booking/pages/booking_calendar_page.dart';
import '../../kapster/pages/kapster_map_page.dart';

class BarbershopDetailPage extends StatefulWidget {
  final Barbershop barbershop;

  const BarbershopDetailPage({
    super.key,
    required this.barbershop,
  });

  @override
  State<BarbershopDetailPage> createState() => _BarbershopDetailPageState();
}

class _BarbershopDetailPageState extends State<BarbershopDetailPage> {
  double? _cachedUserLat;
  double? _cachedUserLng;

  @override
  void initState() {
    super.initState();
    appState.addListener(_onState);
    _tryInjectUserLatLng();
  }

  @override
  void dispose() {
    appState.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    if (mounted) setState(() {});
  }

  void _tryInjectUserLatLng() {
    try {
      final lastLat = appState.lastKnownLat;
      final lastLng = appState.lastKnownLng;
      if (lastLat != null && lastLng != null) {
        _cachedUserLat = lastLat;
        _cachedUserLng = lastLng;
      }
    } catch (_) {}
  }

  BarbershopProfile? get _profile => appState.barbershopByIdOrName(widget.barbershop.name);

  List<ServiceItem> get _services => _profile?.services ?? const [];
  List<String> get _galleryImages => _profile?.gallery ?? const [];
  List<BarbershopKapster> get _shopKapsters => _profile?.kapsters ?? const [];

  List<Kapster> get _kapsters {
    return _shopKapsters.map((bk) => Kapster(
          nama: bk.name,
          fotoUrl: bk.photoUrl,
          rating: bk.rating,
          spesialisasi: [bk.specialty],
          isReady: bk.isActive,
        )).toList();
  }

  void _navigateBooking({Kapster? k}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BookingCalendarPage(initialBarbershop: widget.barbershop, initialKapster: k),
      ),
    );
  }

  Future<void> _launchMaps() async {
    final lat = widget.barbershop.latitude ?? _profile?.latitude;
    final lng = widget.barbershop.longitude ?? _profile?.longitude;
    Uri uri;
    if (lat != null && lng != null) {
      String originParam = '';
      if (_cachedUserLat != null && _cachedUserLng != null) {
        originParam = 'origin=$_cachedUserLat,$_cachedUserLng&';
      }
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&${originParam}destination=$lat,$lng&travelmode=driving',
      );
    } else {
      final query = Uri.encodeComponent(widget.barbershop.name);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  Future<void> _launchWA() async {
    final phone = _profile?.phone ?? '';
    final msg =
        'Halo, saya ingin tanya-tanya tentang ${widget.barbershop.name}. Apakah bisa bantu?';
    final waNumber = phone.isNotEmpty && !phone.startsWith('62')
        ? '62${phone.replaceFirst('0', '')}'
        : (phone.isNotEmpty ? phone : '6281234567890');
    final uri =
        Uri.parse('https://wa.me/$waNumber?text=${Uri.encodeComponent(msg)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  Widget _emptyHint(String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: TrimeColors.textMuted),
          const SizedBox(height: 10),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: TrimeColors.textMuted, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _imageProvider(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        errorWidget: (_, err, stack) => Container(
          color: TrimeColors.surfaceAlt,
          child: Icon(Icons.image, color: TrimeColors.primaryNavy.withValues(alpha: 0.4)),
        ),
      );
    }
    return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, err, stack) => Container(
      color: TrimeColors.surfaceAlt,
      child: Icon(Icons.image, color: TrimeColors.primaryNavy.withValues(alpha: 0.4)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isFav = appState.isFavoriteBarbershop(widget.barbershop.name);
    return Scaffold(
      backgroundColor: TrimeColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: TrimeColors.primaryNavy,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: isFav ? 'Hapus Favorit' : 'Tambah Favorit',
                onPressed: () {
                  appState.toggleFavoriteBarbershop(widget.barbershop.name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        isFav
                            ? '${widget.barbershop.name} dihapus dari favorit'
                            : '💖 ${widget.barbershop.name} ditambahkan ke favorit',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? TrimeColors.dangerRed : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Share',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Link dibagikan!'),
                  ),
                ),
                icon: const Icon(Icons.share),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.barbershop.imageUrl != null &&
                      widget.barbershop.imageUrl!.isNotEmpty)
                    _imageProvider(widget.barbershop.imageUrl!)
                  else if (_profile?.coverUrl != null && _profile!.coverUrl!.isNotEmpty)
                    _imageProvider(_profile!.coverUrl!)
                  else
                    _buildHeroPlaceholder(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TrimeSpacing.lg,
                TrimeSpacing.lg,
                TrimeSpacing.lg,
                TrimeSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _buildActionRow(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _buildSectionTitle('📍 Lokasi'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _buildMapPreview(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _buildSectionTitle('💈 Kapster di Toko Ini'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _buildKapsterList(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _buildSectionTitle('✨ Daftar Layanan'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _buildServiceList(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _buildSectionTitle('📸 Galeri'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _buildGallery(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(),
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: TrimeColors.surfaceAlt,
      child: Icon(
        Icons.store,
        size: 80,
        color: TrimeColors.primaryNavy.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildHeader() {
    final addr = _profile?.address ?? '';
    final hours = _profile?.hours.isNotEmpty == true ? _profile!.hours : widget.barbershop.durationOpen;
    final rating = _profile?.rating ?? widget.barbershop.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.barbershop.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: TrimeColors.textPrimary,
              ),
        ),
        const SizedBox(height: TrimeSpacing.xs),
        Row(
          children: [
            RatingStars(
              rating: rating,
              size: 16,
              showRatingText: true,
            ),
            const SizedBox(width: TrimeSpacing.sm),
            if (hours.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hours.toLowerCase().contains('buka')
                      ? TrimeColors.successGreen.withValues(alpha: 0.15)
                      : TrimeColors.textMuted.withValues(alpha: 0.15),
                  borderRadius: TrimeSpacing.radiusPill,
                ),
                child: Text(
                  hours,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hours.toLowerCase().contains('buka')
                        ? TrimeColors.successGreen
                        : TrimeColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        if (addr.isNotEmpty) ...[
          const SizedBox(height: TrimeSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: TrimeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  addr,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: TrimeColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: TrimeSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: TrimeColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.barbershop.distanceKm.toStringAsFixed(1)} km dari lokasimu',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: TrimeColors.textSecondary,
              ),
            ),
          ],
        ),
        if (hours.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: TrimeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Senin - Minggu · $hours',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: TrimeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _launchWA,
            style: OutlinedButton.styleFrom(
              foregroundColor: TrimeColors.successGreen,
              side: const BorderSide(color: TrimeColors.successGreen),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('Chat'),
          ),
        ),
        const SizedBox(width: TrimeSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _launchMaps,
            style: OutlinedButton.styleFrom(
              foregroundColor: TrimeColors.secondaryBlue,
              side: const BorderSide(color: TrimeColors.secondaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Rute'),
          ),
        ),
        const SizedBox(width: TrimeSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KapsterMapPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: TrimeColors.primaryNavy,
              side: const BorderSide(color: TrimeColors.primaryNavy),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Map'),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    final lat = widget.barbershop.latitude ?? _profile?.latitude;
    final lng = widget.barbershop.longitude ?? _profile?.longitude;
    final bool hasCoords = (lat != null && lng != null);
    final shopPos = latlong.LatLng(
      lat ?? -6.9667,
      lng ?? 110.4167,
    );

    return InkWell(
      onTap: _launchMaps,
      borderRadius: TrimeSpacing.radiusMd,
      child: Container(
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: TrimeSpacing.radiusMd,
          border: Border.all(color: TrimeColors.surfaceAlt),
        ),
        child: hasCoords
            ? Stack(
                fit: StackFit.expand,
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: shopPos,
                      initialZoom: 16,
                      interactionOptions:
                          const InteractionOptions(flags: 0),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.trime.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: shopPos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.place,
                              color: Colors.red,
                              size: 40,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black26)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Lihat rute & lokasi di Google Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildNoCoordsFallback(),
      ),
    );
  }

  Widget _buildNoCoordsFallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: TrimeColors.surfaceAlt,
          child: const Center(
            child: Icon(
              Icons.location_off_outlined,
              color: TrimeColors.textSecondary,
              size: 36,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Tap untuk cari lokasi di Google Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKapsterList() {
    final list = _kapsters;
    if (list.isEmpty) {
      return _emptyHint(
        'Belum ada kapster yang ditambahkan pemilik toko.\n\nMitra bisa menambahkan kapster internal di dashboard.',
        Icons.content_cut,
      );
    }
    return Column(
      children: list.map((k) {
        return Padding(
          padding: const EdgeInsets.only(bottom: TrimeSpacing.sm),
          child: CardKapster(
            kapster: k,
            onTap: () => _navigateBooking(k: k),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceList() {
    if (_services.isEmpty) {
      return _emptyHint(
        'Belum ada layanan yang didaftarkan.\n\nMitra bisa menambahkan daftar layanan di dashboard toko.',
        Icons.list_alt_outlined,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _services.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TrimeSpacing.md,
                vertical: TrimeSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _services[i].name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _services[i].duration,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: TrimeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(_services[i].price)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: TrimeColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            if (i != _services.length - 1)
              const Divider(height: 1, color: TrimeColors.surfaceAlt),
          ],
        ],
      ),
    );
  }

  Widget _buildGallery() {
    if (_galleryImages.isEmpty) {
      return _emptyHint(
        'Belum ada foto galeri.\n\nMitra bisa menambahkan foto-foto toko via dashboard.',
        Icons.image_outlined,
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: _galleryImages.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _imageProvider(url),
        );
      }).toList(),
    );
  }

  Widget _buildBottomCTA() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          TrimeSpacing.lg,
          TrimeSpacing.sm,
          TrimeSpacing.lg,
          TrimeSpacing.md,
        ),
        decoration: BoxDecoration(
          color: TrimeColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: '💈 Booking Sekarang',
                prefixIcon: Icons.event_available,
                onPressed: () => _navigateBooking(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
