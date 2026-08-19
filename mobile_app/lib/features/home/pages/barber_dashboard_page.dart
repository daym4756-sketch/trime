import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/smart_image.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/app_state.dart';

class BarberDashboardPage extends StatefulWidget {
  const BarberDashboardPage({super.key});

  @override
  State<BarberDashboardPage> createState() => _BarberDashboardPageState();
}

class _BarberDashboardPageState extends State<BarberDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final AuthService _authService = AuthService();

  String _ownerId = '';

  String _shopName = '';
  String _shopAddress = '';
  String _shopPhone = '';
  String _shopHours = '';
  String _shopCover = '';
  double _shopLat = 0.0;
  double _shopLng = 0.0;

  List<String> _gallery = [];
  List<ServiceItem> _services = [];
  List<BarbershopKapster> _kapsters = [];

  static const latlong.LatLng _fallback = latlong.LatLng(-6.9667, 110.4167);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    appState.addListener(_onState);
    _initFromCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    appState.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    if (!mounted) return;
    _initFromCurrentUser();
    setState(() {});
  }

  void _initFromCurrentUser() {
    final user = _authService.currentUser;
    if (user != null) {
      _ownerId = user.id;
      final active = appState.activeBarbershopForOwner(_ownerId);
      _shopName = active.name;
      _shopAddress = active.address;
      _shopPhone = active.phone;
      _shopHours = active.hours;
      _shopCover = active.coverUrl ?? '';
      _shopLat = active.latitude ?? 0.0;
      _shopLng = active.longitude ?? 0.0;
      _gallery = List.from(active.gallery);
      _services = List.from(active.services);
      _kapsters = List.from(active.kapsters);
    }
  }

  Future<void> _persist() async {
    if (_ownerId.isEmpty) {
      final user = _authService.currentUser;
      if (user == null) return;
      _ownerId = user.id;
    }
    final existing = appState.activeBarbershopForOwner(_ownerId);
    final profile = BarbershopProfile(
      id: existing.id,
      ownerUserId: _ownerId,
      name: _shopName.trim().isEmpty ? 'Barbershop Saya' : _shopName.trim(),
      address: _shopAddress,
      phone: _shopPhone,
      hours: _shopHours,
      coverUrl: _shopCover.isEmpty ? null : _shopCover,
      latitude: _shopLat == 0.0 ? null : _shopLat,
      longitude: _shopLng == 0.0 ? null : _shopLng,
      rating: existing.rating,
      isNew: existing.isNew,
      gallery: _gallery,
      services: _services,
      kapsters: _kapsters,
    );
    await appState.upsertBarbershop(profile);
  }

  Future<void> _editField({
    required String title,
    required String initial,
    required IconData icon,
    TextInputType? keyboard,
    int maxLines = 1,
    required ValueChanged<String> onSave,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.primaryNavy),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => onSave(result));
      await _persist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, content: Text('$title diperbarui')),
        );
      }
    }
  }

  Future<void> _pickCover() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;
    setState(() => _shopCover = photo.path);
    await _persist();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Cover toko diperbarui')),
      );
    }
  }

  Future<void> _addGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;
    setState(() => _gallery.add(photo.path));
    await _persist();
  }

  Future<void> _editLatLng() async {
    final latC = TextEditingController(text: _shopLat == 0.0 ? '' : _shopLat.toString());
    final lngC = TextEditingController(text: _shopLng == 0.0 ? '' : _shopLng.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text('Koordinat Lokasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final pos = await Geolocator.getCurrentPosition();
                        latC.text = pos.latitude.toString();
                        lngC.text = pos.longitude.toString();
                      } catch (_) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Gagal mengambil lokasi')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text('Gunakan Lokasi Saya'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: latC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                prefixIcon: Icon(Icons.explore),
                border: OutlineInputBorder(),
                hintText: 'cth: -6.9680',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lngC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                prefixIcon: Icon(Icons.explore_outlined),
                border: OutlineInputBorder(),
                hintText: 'cth: 110.4150',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.primaryNavy),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == true) {
      final lat = double.tryParse(latC.text.trim());
      final lng = double.tryParse(lngC.text.trim());
      if (lat != null && lng != null) {
        setState(() {
          _shopLat = lat;
          _shopLng = lng;
        });
        await _persist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Lokasi toko disimpan')),
          );
        }
      }
    }
  }

  Future<void> _addService() async {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final durC = TextEditingController(text: '45 menit');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text('Tambah Layanan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama Layanan',
                prefixIcon: Icon(Icons.content_cut),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durC,
              decoration: const InputDecoration(
                labelText: 'Durasi (cth: 45 menit)',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.primaryNavy),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (result == true && nameC.text.trim().isNotEmpty) {
      setState(() {
        _services.add(ServiceItem(
          id: DateTime.now().millisecondsSinceEpoch,
          name: nameC.text.trim(),
          price: int.tryParse(priceC.text.replaceAll(RegExp(r'\D'), '')) ?? 0,
          duration: durC.text.trim().isEmpty ? '45 menit' : durC.text.trim(),
        ));
      });
      await _persist();
    }
  }

  void _deleteService(int id) async {
    setState(() => _services.removeWhere((s) => s.id == id));
    await _persist();
  }

  Future<void> _addKapster() async {
    final nameC = TextEditingController();
    final specC = TextEditingController(text: 'Umum');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text('Tambah Kapster', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama Kapster',
                prefixIcon: Icon(Icons.person_add),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: specC,
              decoration: const InputDecoration(
                labelText: 'Spesialisasi',
                prefixIcon: Icon(Icons.star_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.primaryNavy),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (result == true && nameC.text.trim().isNotEmpty) {
      setState(() {
        _kapsters.add(BarbershopKapster(
          id: DateTime.now().millisecondsSinceEpoch,
          name: nameC.text.trim(),
          photoUrl: null,
          rating: 0.0,
          specialty: specC.text.trim().isEmpty ? 'Umum' : specC.text.trim(),
          isActive: true,
        ));
      });
      await _persist();
    }
  }

  void _toggleKapsterStatus(int id) async {
    setState(() {
      final idx = _kapsters.indexWhere((k) => k.id == id);
      if (idx >= 0) {
        _kapsters[idx] = _kapsters[idx].copyWith(isActive: !_kapsters[idx].isActive);
      }
    });
    await _persist();
  }

  void _deleteKapster(int id) async {
    setState(() => _kapsters.removeWhere((k) => k.id == id));
    await _persist();
  }

  Widget _buildHeaderShopSelector() {
    final owned = appState.barbershopsForOwner(_ownerId);
    final active = appState.activeBarbershopForOwner(_ownerId);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...owned.map((shop) {
            final isSel = shop.id == active.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () {
                  appState.setActiveBarbershopForOwner(_ownerId, shop.id);
                  _initFromCurrentUser();
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.amber : Colors.white.withValues(alpha: 0.25),
                    borderRadius: TrimeSpacing.radiusPill,
                    border: Border.all(
                      color: isSel ? Colors.amber : Colors.white38,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront,
                        size: 12,
                        color: isSel ? TrimeColors.primaryNavy : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shop.name.isEmpty ? 'Barbershop' : shop.name,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? TrimeColors.primaryNavy : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          InkWell(
            onTap: () async {
              final newShop = await appState.createNewBarbershopForOwner(_ownerId);
              _initFromCurrentUser();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: TrimeColors.successGreen,
                    content: Text('Barbershop baru "${newShop.name}" dibuat!'),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: TrimeSpacing.radiusPill,
                border: Border.all(color: Colors.white38),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Tambah Toko',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userBookings = appState.bookings;
    final todayRevenue = userBookings
        .where((b) => b.status == 'done')
        .fold<int>(0, (sum, b) => sum + b.price);
    final confirmedCount = userBookings.where((b) => b.status == 'confirmed').length;
    final pendingCount = userBookings.where((b) => b.status == 'pending').length;

    return Scaffold(
      backgroundColor: TrimeColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            backgroundColor: TrimeColors.primaryNavy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SmartImage(
                    pathOrUrl: _shopCover,
                    fit: BoxFit.cover,
                    placeholder: _coverPlaceholder(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: TrimeSpacing.lg,
                    right: TrimeSpacing.lg,
                    bottom: TrimeSpacing.lg,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_ownerId.isNotEmpty) _buildHeaderShopSelector(),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _editField(
                                    title: 'Nama Barbershop',
                                    initial: _shopName,
                                    icon: Icons.store,
                                    onSave: (v) => _shopName = v,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _shopName.isEmpty ? 'Tap isi nama toko' : _shopName,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                onPressed: _pickCover,
                                icon: const Icon(Icons.photo_camera, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _editField(
                                    title: 'Alamat',
                                    initial: _shopAddress,
                                    icon: Icons.location_on_outlined,
                                    maxLines: 2,
                                    onSave: (v) => _shopAddress = v,
                                  ),
                                  child: Text(
                                    _shopAddress.isEmpty ? 'Tap isi alamat' : _shopAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _editField(
                                  title: 'Nomor WhatsApp',
                                  initial: _shopPhone,
                                  icon: Icons.phone,
                                  keyboard: TextInputType.phone,
                                  onSave: (v) => _shopPhone = v,
                                ),
                                child: Text(
                                  _shopPhone.isEmpty ? 'Tap isi WA' : _shopPhone,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _editField(
                                  title: 'Jam Operasional',
                                  initial: _shopHours,
                                  icon: Icons.access_time,
                                  onSave: (v) => _shopHours = v,
                                ),
                                child: Flexible(
                                  child: Text(
                                    _shopHours.isEmpty ? 'Tap isi jam' : _shopHours,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: TrimeColors.surface,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    tabs: const [
                      Tab(height: 44, text: 'Ringkasan'),
                      Tab(height: 44, text: 'Booking'),
                      Tab(height: 44, text: 'Layanan'),
                      Tab(height: 44, text: 'Data Toko'),
                    ],
                  ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverview(todayRevenue, confirmedCount, pendingCount),
            _buildBookingsTab(userBookings),
            _buildServicesTab(),
            _buildDataTokoTab(),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: TrimeColors.surfaceAlt,
        child: Icon(
          Icons.store,
          size: 72,
          color: TrimeColors.primaryNavy.withValues(alpha: 0.4),
        ),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return TrimeColors.secondaryBlue;
      case 'pending':
        return Colors.orange;
      case 'done':
        return TrimeColors.successGreen;
      default:
        return TrimeColors.textMuted;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'pending':
        return 'Menunggu';
      case 'done':
        return 'Selesai';
      default:
        return '-';
    }
  }

  Widget _buildOverview(int revenue, int confirmed, int pending) {
    final userBookings = appState.bookings;
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Pendapatan Hari Ini',
                value: _rupiah.format(revenue),
                icon: Icons.payments_outlined,
                color: TrimeColors.successGreen,
              ),
            ),
            const SizedBox(width: TrimeSpacing.sm),
            Expanded(
              child: _statCard(
                title: 'Booking Selesai',
                value: '${userBookings.where((b) => b.status == 'done').length}',
                icon: Icons.check_circle_outline,
                color: TrimeColors.secondaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: TrimeSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Perlu Konfirmasi',
                value: '$pending',
                icon: Icons.pending_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: TrimeSpacing.sm),
            Expanded(
              child: _statCard(
                title: 'Booking Aktif',
                value: '$confirmed',
                icon: Icons.event_available,
                color: TrimeColors.primaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: TrimeSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Booking Terbaru',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: TrimeSpacing.sm),
        if (userBookings.isEmpty)
          _emptyHint('Belum ada booking. Akan muncul otomatis saat pelanggan booking.',
              Icons.event_note_outlined)
        else
          for (final b in userBookings.take(3)) _bookingItem(b),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(TrimeSpacing.md),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        boxShadow: [
          BoxShadow(
            color: TrimeColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: TrimeSpacing.sm),
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: TrimeColors.textSecondary,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab(List<BookingItem> all) {
    if (all.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [_emptyHint('Belum ada booking dari pelanggan.', Icons.event_note_outlined)],
      );
    }
    return ListView.separated(
      padding: TrimeSpacing.screenPadding,
      itemCount: all.length,
      separatorBuilder: (_, idx) => const SizedBox(height: TrimeSpacing.sm),
      itemBuilder: (context, i) => _bookingItem(all[i]),
    );
  }

  Widget _bookingItem(BookingItem b) {
    return Container(
      padding: const EdgeInsets.all(TrimeSpacing.md),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(b.id,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, color: TrimeColors.primaryNavy)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(b.status).withValues(alpha: 0.12),
                  borderRadius: TrimeSpacing.radiusPill,
                ),
                child: Text(
                  _statusText(b.status),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(b.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TrimeSpacing.xs),
          Text(b.customerName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text('${b.serviceName} • ${b.kapsterName}',
              style: TextStyle(color: TrimeColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: TrimeColors.textMuted),
              const SizedBox(width: 4),
              Text(
                DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(b.date),
                style: const TextStyle(color: TrimeColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          if (b.status != 'done') ...[
            const SizedBox(height: TrimeSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Hubungi WA',
                    mini: true,
                    prefixIcon: Icons.chat,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Membuka WhatsApp customer...')),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: TrimeColors.successGreen),
                    icon: const Icon(Icons.check, size: 18),
                    onPressed: () {
                      final next = (b.status == 'pending') ? 'confirmed' : 'done';
                      appState.updateBookingStatus(b.id, next);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        Row(
          children: [
            Text('Daftar Layanan (${_services.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            PrimaryButton(
              label: 'Tambah',
              mini: true,
              prefixIcon: Icons.add,
              onPressed: _addService,
            ),
          ],
        ),
        const SizedBox(height: TrimeSpacing.md),
        if (_services.isEmpty)
          _emptyHint('Belum ada layanan. Tap Tambah untuk menambahkan.', Icons.list_alt_outlined)
        else
          Container(
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
                        horizontal: TrimeSpacing.md, vertical: TrimeSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: TrimeColors.primaryNavy.withValues(alpha: 0.08),
                            borderRadius: TrimeSpacing.radiusSm,
                          ),
                          child: const Icon(Icons.content_cut, color: TrimeColors.primaryNavy),
                        ),
                        const SizedBox(width: TrimeSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_services[i].name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              Text(
                                _services[i].duration,
                                style: TextStyle(
                                    color: TrimeColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _rupiah.format(_services[i].price),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: TrimeColors.primaryNavy,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteService(_services[i].id),
                          icon:
                              const Icon(Icons.delete_outline, color: TrimeColors.dangerRed, size: 20),
                        ),
                      ],
                    ),
                  ),
                  if (i != _services.length - 1)
                    const Divider(height: 1, color: TrimeColors.surfaceAlt),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDataTokoTab() {
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        _sectionHeader('Galeri Toko', action: _addGallery, actionLabel: 'Tambah'),
        const SizedBox(height: TrimeSpacing.sm),
        _gallery.isEmpty
            ? _emptyHint('Tambah foto toko untuk menarik pelanggan.', Icons.photo_library_outlined)
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _gallery.length + 1,
                itemBuilder: (context, i) {
                  if (i == _gallery.length) {
                    return GestureDetector(
                      onTap: _addGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          color: TrimeColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: TrimeColors.primaryNavy.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                              width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 28, color: TrimeColors.primaryNavy),
                            SizedBox(height: 4),
                            Text('Tambah',
                                style: TextStyle(
                                    color: TrimeColors.primaryNavy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }
                  final url = _gallery[i];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SmartImage(pathOrUrl: url, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _gallery.removeAt(i));
                            await _persist();
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: TrimeColors.dangerRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        const SizedBox(height: TrimeSpacing.lg),
        _sectionHeader('Daftar Kapster (${_kapsters.length})',
            action: _addKapster, actionLabel: 'Tambah'),
        const SizedBox(height: TrimeSpacing.sm),
        if (_kapsters.isEmpty)
          _emptyHint('Belum ada kapster. Tap Tambah untuk mendaftarkan kapster.',
              Icons.person_add_outlined)
        else
          Container(
            decoration: BoxDecoration(
              color: TrimeColors.surface,
              borderRadius: TrimeSpacing.radiusMd,
              border: Border.all(color: TrimeColors.surfaceAlt),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _kapsters.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(TrimeSpacing.sm),
                    child: Row(
                      children: [
                        SmartAvatar(
                          pathOrUrl: _kapsters[i].photoUrl,
                          radius: 24,
                          fallbackIcon: Icons.person,
                        ),
                        const SizedBox(width: TrimeSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_kapsters[i].name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${_kapsters[i].specialty} • ⭐ ${_kapsters[i].rating.toStringAsFixed(1)}',
                                style: TextStyle(fontSize: 12, color: TrimeColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _kapsters[i].isActive,
                          activeThumbColor: TrimeColors.successGreen,
                          onChanged: (_) => _toggleKapsterStatus(_kapsters[i].id),
                        ),
                        IconButton(
                          onPressed: () => _deleteKapster(_kapsters[i].id),
                          icon:
                              const Icon(Icons.delete_outline, color: TrimeColors.dangerRed, size: 20),
                        ),
                      ],
                    ),
                  ),
                  if (i != _kapsters.length - 1)
                    const Divider(height: 1, color: TrimeColors.surfaceAlt),
                ],
              ],
            ),
          ),
        const SizedBox(height: TrimeSpacing.lg),
        _sectionHeader('Lokasi Toko di Peta'),
        const SizedBox(height: TrimeSpacing.sm),
        _mapPreview(),
        const SizedBox(height: 6),
        Center(
          child: Text(
            (_shopLat == 0.0 && _shopLng == 0.0)
                ? 'Lokasi belum diatur'
                : 'Lat: ${_shopLat.toStringAsFixed(4)}, Lng: ${_shopLng.toStringAsFixed(4)}',
            style: TextStyle(color: TrimeColors.textMuted, fontSize: 11),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: _editLatLng,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Ubah Titik Lokasi'),
          ),
        ),
        const SizedBox(height: TrimeSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              await _persist();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: TrimeColors.successGreen,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Data toko berhasil disimpan!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: TrimeColors.primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusMd),
            ),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(
              'Simpan Perubahan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? action, String? actionLabel}) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (action != null) ...[
          const Spacer(),
          TextButton.icon(
            onPressed: action,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel ?? 'Tambah'),
          ),
        ],
      ],
    );
  }

  Widget _emptyHint(String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: TrimeColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: TrimeColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _mapPreview() {
    final hasCoords = _shopLat != 0.0 || _shopLng != 0.0;
    final pos = hasCoords ? latlong.LatLng(_shopLat, _shopLng) : _fallback;
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: _editLatLng,
          borderRadius: TrimeSpacing.radiusMd,
          child: Container(
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: TrimeSpacing.radiusMd,
              border: Border.all(color: TrimeColors.surfaceAlt),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: pos,
                    initialZoom: hasCoords ? 16 : 12,
                    interactionOptions: const InteractionOptions(flags: 0),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.trime.app',
                    ),
                    if (hasCoords)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.place,
                              color: Colors.red,
                              size: 40,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
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
                            'Tap untuk atur koordinat lokasi toko',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
