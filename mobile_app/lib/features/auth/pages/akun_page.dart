import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/smart_image.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/app_state.dart';
import 'login_page.dart';

class AkunPage extends StatefulWidget {
  final AuthService authService;

  const AkunPage({
    super.key,
    required this.authService,
  });

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  final ImagePicker _picker = ImagePicker();

  // Shared profile controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  // Barber-specific controllers
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _shopAddressCtrl;
  late final TextEditingController _shopHoursCtrl;

  // Kapster-specific controllers
  late final TextEditingController _specialtiesCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_onStateChanged);
    final user = widget.authService.currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');

    // Barber init
    final ownerId = user?.id ?? '';
    final shop = ownerId.isNotEmpty ? appState.activeBarbershopForOwner(ownerId) : null;
    _shopNameCtrl = TextEditingController(text: shop?.name ?? '');
    _shopAddressCtrl = TextEditingController(text: shop?.address ?? '');
    _shopHoursCtrl = TextEditingController(text: shop?.hours ?? '');

    // Kapster init
    final kapster = ownerId.isNotEmpty ? appState.kapsterForUser(ownerId) : null;
    _specialtiesCtrl = TextEditingController(
      text: kapster?.specialties.join(', ') ?? '',
    );
  }

  void _onStateChanged() {
    if (!mounted) return;
    final user = widget.authService.currentUser;
    if (user != null && user.role == UserRole.mitra) {
      final shop = appState.activeBarbershopForOwner(user.id);
      if (_shopNameCtrl.text != shop.name) _shopNameCtrl.text = shop.name;
      if (_shopAddressCtrl.text != shop.address) _shopAddressCtrl.text = shop.address;
      if (_shopHoursCtrl.text != shop.hours) _shopHoursCtrl.text = shop.hours;
    }
    setState(() {});
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _shopNameCtrl.dispose();
    _shopAddressCtrl.dispose();
    _shopHoursCtrl.dispose();
    _specialtiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _editPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;
    await widget.authService.updateProfile(photoUrl: photo.path);
    if (mounted) setState(() {});
  }

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: const Text('Anda akan keluar dari akun ini. Tetap lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.dangerRed),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginPage(authService: widget.authService),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _saveChanges() async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      // Save auth profile
      await widget.authService.updateProfile(
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        phoneNumber: phone.isNotEmpty ? phone : null,
      );

      final role = user.role;

      if (role == UserRole.mitra) {
        // Save active barbershop profile
        final ownerId = user.id;
        final existing = appState.activeBarbershopForOwner(ownerId);
        final shopName = _shopNameCtrl.text.trim();
        final shopAddress = _shopAddressCtrl.text.trim();
        final shopHours = _shopHoursCtrl.text.trim();

        final profile = BarbershopProfile(
          id: existing.id,
          ownerUserId: ownerId,
          name: shopName.isNotEmpty ? shopName : 'Barbershop Saya',
          address: shopAddress,
          phone: phone.isNotEmpty ? phone : existing.phone,
          hours: shopHours,
          coverUrl: existing.coverUrl,
          latitude: existing.latitude,
          longitude: existing.longitude,
          rating: existing.rating,
          isNew: existing.isNew,
          gallery: existing.gallery,
          services: existing.services,
          kapsters: existing.kapsters,
        );
        await appState.upsertBarbershop(profile);
      } else if (role == UserRole.kapster) {
        // Save kapster profile
        final userId = user.id;
        final existing = appState.kapsterForUser(userId);
        final specialtiesList = _specialtiesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final profile = KapsterProfile(
          id: existing?.id ?? 'kap_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          name: name.isNotEmpty ? name : (existing?.name ?? ''),
          photoUrl: existing?.photoUrl,
          rating: existing?.rating ?? 0.0,
          specialties: specialtiesList,
          badgeType: existing?.badgeType ?? '',
          isReady: existing?.isReady ?? false,
          topRank: existing?.topRank,
          latitude: existing?.latitude,
          longitude: existing?.longitude,
        );
        await appState.upsertKapster(profile);
      }

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
                  'Perubahan berhasil disimpan!',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _roleText(UserRole role) {
    switch (role) {
      case UserRole.mitra:
        return 'Mitra Barbershop';
      case UserRole.kapster:
        return 'Kapster Profesional';
      case UserRole.pelanggan:
        return 'Pelanggan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: TrimeColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login_rounded, size: 64, color: TrimeColors.textMuted),
              const SizedBox(height: TrimeSpacing.md),
              PrimaryButton(
                label: 'Masuk ke Akun',
                prefixIcon: Icons.login,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginPage(authService: widget.authService),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TrimeColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              TrimeSpacing.xl,
              TrimeSpacing.xxl + 32,
              TrimeSpacing.xl,
              TrimeSpacing.xl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [TrimeColors.primaryNavy, TrimeColors.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _editPhoto,
                      child: SmartAvatar(
                        pathOrUrl: user.photoUrl,
                        radius: 48,
                        fallbackIcon: Icons.person,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _editPhoto,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: TrimeColors.primaryNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TrimeSpacing.md),
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: TrimeSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TrimeSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: TrimeSpacing.radiusPill,
                  ),
                  child: Text(
                    _roleText(user.role),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: TrimeSpacing.md),
          Padding(
            padding: TrimeSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── BARBER (MITRA) SETTINGS ───
                if (user.role == UserRole.mitra) ...[
                  _sectionTitle('🏪 Profil Pemilik'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _nameCtrl,
                    label: 'Nama Pemilik',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _phoneCtrl,
                    label: 'Nomor WhatsApp',
                    icon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: TrimeSpacing.lg),
                  _sectionTitle('🏠 Data Barbershop'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _buildBarbershopSelector(user.id),
                  const SizedBox(height: TrimeSpacing.xs),
                  _inputField(
                    controller: _shopNameCtrl,
                    label: 'Nama Barbershop',
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _shopAddressCtrl,
                    label: 'Alamat Toko',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _shopHoursCtrl,
                    label: 'Jam Operasional (cth: 09:00 - 21:00)',
                    icon: Icons.access_time_outlined,
                  ),
                  const SizedBox(height: TrimeSpacing.lg),
                  _saveButton(),
                  const SizedBox(height: TrimeSpacing.lg),
                ],

                // ─── KAPSTER SETTINGS ───
                if (user.role == UserRole.kapster) ...[
                  _sectionTitle('💈 Profil Kapster'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _nameCtrl,
                    label: 'Nama Kapster',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _phoneCtrl,
                    label: 'Nomor WhatsApp',
                    icon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _specialtiesCtrl,
                    label: 'Spesialisasi (pisahkan dengan koma)',
                    icon: Icons.content_cut,
                    hint: 'Pompadour, Fade, Hair Tattoo',
                    maxLines: 2,
                  ),
                  const SizedBox(height: TrimeSpacing.lg),
                  _saveButton(),
                  const SizedBox(height: TrimeSpacing.lg),
                ],

                // ─── PELANGGAN SETTINGS ───
                if (user.role == UserRole.pelanggan) ...[
                  _sectionTitle('Pengaturan Profil'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _nameCtrl,
                    label: 'Nama Lengkap',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: TrimeSpacing.sm),
                  _inputReadOnly(
                    value: user.phoneNumber,
                    label: 'Nomor WhatsApp',
                    icon: Icons.chat_outlined,
                    note: 'Nomor tidak dapat diubah',
                  ),
                  const SizedBox(height: TrimeSpacing.lg),
                  _saveButton(),
                  const SizedBox(height: TrimeSpacing.lg),
                  _sectionTitle('Aktivitas Saya'),
                  const SizedBox(height: TrimeSpacing.sm),
                  _menuCard([
                    _menuTile(
                      icon: Icons.event_note_outlined,
                      title: 'Riwayat Booking',
                      subtitle: 'Semua booking pernah dibuat',
                    ),
                    _menuTile(
                      icon: Icons.favorite_border,
                      title: 'Favorit',
                      subtitle: 'Barbershop & kapster disimpan',
                    ),
                    _menuTile(
                      icon: Icons.reviews_outlined,
                      title: 'Review Saya',
                      subtitle: 'Ulasan yang pernah kamu tulis',
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: TrimeSpacing.lg),
                ],

                // ─── LAINNYA (all roles) ───
                _sectionTitle('Lainnya'),
                const SizedBox(height: TrimeSpacing.sm),
                _menuCard([
                  _menuTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    subtitle: 'Kelola notifikasi booking & promo',
                  ),
                  if (user.role == UserRole.pelanggan) ...[
                    _menuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Alamat',
                      subtitle: 'Atur lokasi default',
                    ),
                    _menuTile(
                      icon: Icons.payment_outlined,
                      title: 'Metode Pembayaran',
                      subtitle: 'Tambah/kartu, e-wallet',
                    ),
                  ],
                  _menuTile(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    subtitle: 'FAQ, chat CS',
                  ),
                  _menuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Data kamu aman bersama kami',
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: TrimeSpacing.xl),
                PrimaryButton(
                  label: 'Keluar Akun',
                  prefixIcon: Icons.logout_outlined,
                  onPressed: _confirmLogout,
                ),
                const SizedBox(height: TrimeSpacing.xxl * 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildBarbershopSelector(String ownerId) {
    final ownedShops = appState.barbershopsForOwner(ownerId);
    final activeShop = appState.activeBarbershopForOwner(ownerId);

    return Container(
      margin: const EdgeInsets.only(bottom: TrimeSpacing.xs),
      padding: const EdgeInsets.all(TrimeSpacing.md),
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.primaryNavy.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: TrimeColors.primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text(
                'Kelola Toko (${ownedShops.length} Toko)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final newShop = await appState.createNewBarbershopForOwner(ownerId);
                  _shopNameCtrl.text = newShop.name;
                  _shopAddressCtrl.text = newShop.address;
                  _shopHoursCtrl.text = newShop.hours;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: TrimeColors.successGreen,
                        content: Text('Toko baru "${newShop.name}" berhasil dibuat!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Toko'),
                style: TextButton.styleFrom(
                  foregroundColor: TrimeColors.primaryNavy,
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          if (ownedShops.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ownedShops.map((shop) {
                  final isSelected = shop.id == activeShop.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        shop.name.isEmpty ? 'Toko Tanpa Nama' : shop.name,
                        style: GoogleFonts.poppins(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          color: isSelected ? Colors.white : TrimeColors.textPrimary,
                        ),
                      ),
                      selectedColor: TrimeColors.primaryNavy,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          appState.setActiveBarbershopForOwner(ownerId, shop.id);
                          _shopNameCtrl.text = shop.name;
                          _shopAddressCtrl.text = shop.address;
                          _shopHoursCtrl.text = shop.hours;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: TrimeColors.textPrimary,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: TrimeColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: TrimeColors.primaryNavy, size: 20),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: TrimeColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusMd,
          borderSide: const BorderSide(color: TrimeColors.surfaceAlt),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusMd,
          borderSide: const BorderSide(color: TrimeColors.surfaceAlt),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusMd,
          borderSide: const BorderSide(color: TrimeColors.primaryNavy, width: 2),
        ),
        filled: true,
        fillColor: TrimeColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TrimeSpacing.md,
          vertical: TrimeSpacing.md,
        ),
      ),
    );
  }

  Widget _inputReadOnly({
    required String value,
    required String label,
    required IconData icon,
    String? note,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TrimeSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Row(
        children: [
          Icon(icon, color: TrimeColors.textMuted, size: 20),
          const SizedBox(width: TrimeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: TrimeColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TrimeColors.textSecondary,
                  ),
                ),
                if (note != null)
                  Text(
                    note,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: TrimeColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: TrimeColors.textMuted),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveChanges,
        style: FilledButton.styleFrom(
          backgroundColor: TrimeColors.primaryNavy,
          disabledBackgroundColor: TrimeColors.primaryNavy.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusMd),
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        boxShadow: [
          BoxShadow(
            color: TrimeColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    bool isLast = false,
  }) {
    final defaultAction = onTap ??
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title - segera hadir!')),
          );
        };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? defaultAction : null,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TrimeSpacing.md,
            TrimeSpacing.md,
            TrimeSpacing.sm,
            TrimeSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TrimeColors.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: TrimeSpacing.radiusSm,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: enabled ? TrimeColors.primaryNavy : TrimeColors.textMuted,
                ),
              ),
              const SizedBox(width: TrimeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: enabled ? TrimeColors.textPrimary : TrimeColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TrimeColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: enabled ? TrimeColors.textMuted : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
