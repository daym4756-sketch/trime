import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/smart_image.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/app_state.dart';

enum SlotStatus { tersedia, penuh, libur }

class KapsterDashboardPage extends StatefulWidget {
  const KapsterDashboardPage({super.key});

  @override
  State<KapsterDashboardPage> createState() => _KapsterDashboardPageState();
}

class _KapsterDashboardPageState extends State<KapsterDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedDay = DateTime.now().weekday - 1;
  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final List<String> _days = const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final List<String> _slots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
    '20:00', '20:30', '21:00',
  ];

  final Map<String, SlotStatus> _daySlots = {};
  bool _reminderBooking = true;
  bool _reminder15min = true;
  bool _reminder1jam = false;
  bool _whatsappNotif = true;

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  String _kapsterId = '';
  String _userId = '';
  String _kapsterName = '';
  String? _kapsterPhoto;
  double _kapsterRating = 0.0;
  List<String> _specialties = [];
  String _badgeType = '';
  bool _isReady = false;
  String? _topRank;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initEmptySchedule();
    _initFromCurrentUser();
    appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    appState.removeListener(_onAppStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initEmptySchedule() {
    for (int d = 0; d < 7; d++) {
      for (var s in _slots) {
        _daySlots['$d-$s'] = SlotStatus.libur;
      }
    }
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('kapster_schedule_${_userId.isEmpty ? 'default' : _userId}');
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        for (final entry in map.entries) {
          final idx = int.tryParse(entry.value.toString());
          if (idx != null) _daySlots[entry.key] = SlotStatus.values[idx];
        }
      });
    }
    // Load reminders
    _reminderBooking = prefs.getBool('kap_reminder_booking_$_userId') ?? true;
    _reminder15min = prefs.getBool('kap_reminder_15min_$_userId') ?? true;
    _reminder1jam = prefs.getBool('kap_reminder_1jam_$_userId') ?? false;
    _whatsappNotif = prefs.getBool('kap_wa_notif_$_userId') ?? true;
    if (mounted) setState(() {});
  }

  Future<void> _persistSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, int>{};
    for (final entry in _daySlots.entries) {
      map[entry.key] = entry.value.index;
    }
    await prefs.setString(
      'kapster_schedule_${_userId.isEmpty ? 'default' : _userId}',
      jsonEncode(map),
    );
  }

  Future<void> _persistReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kap_reminder_booking_$_userId', _reminderBooking);
    await prefs.setBool('kap_reminder_15min_$_userId', _reminder15min);
    await prefs.setBool('kap_reminder_1jam_$_userId', _reminder1jam);
    await prefs.setBool('kap_wa_notif_$_userId', _whatsappNotif);
  }

  Future<void> _initFromCurrentUser() async {
    await _authService.init();
    final user = _authService.currentUser;
    if (user != null) {
      _userId = user.id;
      _kapsterName = user.name;
      final existing = appState.kapsterForUser(_userId);
      if (existing != null) {
        _kapsterId = existing.id;
        _kapsterName = existing.name;
        _kapsterPhoto = existing.photoUrl;
        _kapsterRating = existing.rating;
        _specialties = List.from(existing.specialties);
        _badgeType = existing.badgeType;
        _isReady = existing.isReady;
        _topRank = existing.topRank;
        _latitude = existing.latitude;
        _longitude = existing.longitude;
      }
      await _loadSchedule();
    }
    if (mounted) setState(() {});
  }

  Future<void> _persist() async {
    if (_userId.isEmpty) return;
    if (_kapsterId.isEmpty) {
      _kapsterId = 'kap_${DateTime.now().millisecondsSinceEpoch}';
    }
    final profile = KapsterProfile(
      id: _kapsterId,
      userId: _userId,
      name: _kapsterName,
      photoUrl: _kapsterPhoto,
      rating: _kapsterRating,
      specialties: _specialties,
      badgeType: _badgeType,
      isReady: _isReady,
      topRank: _topRank,
      latitude: _latitude,
      longitude: _longitude,
    );
    await appState.upsertKapster(profile);
  }

  SlotStatus _slotStatus(int dayIdx, String slot) =>
      _daySlots['$dayIdx-$slot'] ?? SlotStatus.libur;

  void _toggleSlot(int dayIdx, String slot) {
    setState(() {
      final key = '$dayIdx-$slot';
      final current = _daySlots[key] ?? SlotStatus.libur;
      switch (current) {
        case SlotStatus.tersedia:
          _daySlots[key] = SlotStatus.penuh;
          break;
        case SlotStatus.penuh:
          _daySlots[key] = SlotStatus.libur;
          break;
        case SlotStatus.libur:
          _daySlots[key] = SlotStatus.tersedia;
          break;
      }
    });
  }

  Color _slotColor(SlotStatus s) {
    switch (s) {
      case SlotStatus.tersedia:
        return TrimeColors.successGreen.withValues(alpha: 0.15);
      case SlotStatus.penuh:
        return TrimeColors.dangerRed.withValues(alpha: 0.15);
      case SlotStatus.libur:
        return TrimeColors.surfaceAlt;
    }
  }

  Color _slotTextColor(SlotStatus s) {
    switch (s) {
      case SlotStatus.tersedia:
        return TrimeColors.successGreen;
      case SlotStatus.penuh:
        return TrimeColors.dangerRed;
      case SlotStatus.libur:
        return TrimeColors.textMuted;
    }
  }

  String _slotText(SlotStatus s) {
    switch (s) {
      case SlotStatus.tersedia:
        return 'Tersedia';
      case SlotStatus.penuh:
        return 'Penuh';
      case SlotStatus.libur:
        return 'Libur';
    }
  }

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

  List<BookingItem> get _myBookings {
    final name = _kapsterName;
    return appState.bookings.where((b) => b.kapsterName == name).toList();
  }

  int get _todayEarnings {
    return _myBookings
        .where((b) =>
            b.status == 'done' &&
            DateUtils.isSameDay(b.date, DateTime.now()))
        .fold<int>(0, (sum, b) => sum + b.price);
  }

  int get _todayBookingsDone =>
      _myBookings
          .where((b) =>
              b.status == 'done' &&
              DateUtils.isSameDay(b.date, DateTime.now()))
          .length;

  int get _pendingBookings =>
      _myBookings.where((b) => b.status == 'pending').length;

  int get _availableSlotsToday {
    int c = 0;
    final today = DateTime.now().weekday - 1;
    for (final s in _slots) {
      if (_slotStatus(today, s) == SlotStatus.tersedia) c++;
    }
    return c;
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _kapsterName);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Nama Kapster')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      setState(() => _kapsterName = res);
      await _persist();
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? img = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (img != null && mounted) {
        setState(() => _kapsterPhoto = img.path);
        await _persist();
      }
    } catch (_) {}
  }

  Future<void> _editSpecialties() async {
    final ctrl = TextEditingController(text: _specialties.join(', '));
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Spesialisasi (pisahkan dengan koma)'),
        content: TextField(controller: ctrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Pompadour, Fade, Hair Tattoo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Simpan')),
        ],
      ),
    );
    if (res != null) {
      final list = res.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      setState(() => _specialties = list);
      await _persist();
    }
  }

  Future<void> _editBadge() async {
    final options = ['', 'Kapster Baru', 'Kapster Profesional', 'Master Barber', 'Top Rated'];
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Pilih Badge'),
        children: options.map((o) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, o),
          child: Text(o.isEmpty ? 'Tidak Ada' : o),
        )).toList(),
      ),
    );
    if (res != null) {
      setState(() => _badgeType = res);
      await _persist();
    }
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
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: TrimeColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrimeColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: const Color(0xFF2E3A59),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F2A44), Color(0xFF3D4D7A), Color(0xFF2E3A59)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(TrimeSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: SmartAvatar(
                                pathOrUrl: _kapsterPhoto,
                                radius: 30,
                                fallbackIcon: Icons.person,
                              ),
                            ),
                            const SizedBox(width: TrimeSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _editName,
                                          child: Text(
                                            _kapsterName.isEmpty ? 'Tap untuk isi nama' : _kapsterName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: TrimeSpacing.radiusPill,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                size: 14, color: Color(0xFFFFD700)),
                                            const SizedBox(width: 4),
                                            Text(
                                              _kapsterRating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: _editBadge,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: TrimeSpacing.radiusSm,
                                      ),
                                      child: Text(
                                        _badgeType.isEmpty ? 'Tap pilih badge' : '$_badgeType${_specialties.isNotEmpty ? ' • ${_specialties.take(2).join(', ')}' : ''}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: _editSpecialties,
                                    child: Text(
                                      _specialties.isEmpty ? 'Tap atur spesialisasi' : '💈 ${_specialties.join(', ')}',
                                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TrimeSpacing.md),
                        Row(
                          children: [
                            _quickStat('$_todayBookingsDone', 'Selesai'),
                            const SizedBox(width: TrimeSpacing.md),
                            _quickStat('$_pendingBookings', 'Pending'),
                            const SizedBox(width: TrimeSpacing.md),
                            _quickStat('$_availableSlotsToday', 'Slot Kosong'),
                            const SizedBox(width: TrimeSpacing.md),
                            _quickStat(_rupiah.format(_todayEarnings), 'Pendapatan'),
                          ],
                        ),
                        const SizedBox(height: TrimeSpacing.sm),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: TrimeColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: TrimeColors.primaryNavy,
                  unselectedLabelColor: TrimeColors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(height: 48, text: '📅 Jadwal'),
                    Tab(height: 48, text: '📋 Booking'),
                    Tab(height: 48, text: '🔔 Pengingat'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildScheduleTab(),
            _buildBookingsTab(),
            _buildRemindersTab(),
          ],
        ),
      ),
    );
  }

  Widget _quickStat(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(val,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isSelected = _selectedDay == i;
              final isToday = DateTime.now().weekday - 1 == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TrimeColors.primaryNavy
                        : TrimeColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isToday && !isSelected
                            ? TrimeColors.primaryNavy.withValues(alpha: 0.4)
                            : TrimeColors.surfaceAlt),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isToday)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.circle,
                            size: 6,
                            color: isSelected
                                ? Colors.white
                                : TrimeColors.primaryNavy),
                      ),
                      Text(
                        _days[i],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : TrimeColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: TrimeSpacing.md),
        Container(
          padding: const EdgeInsets.all(TrimeSpacing.sm),
          decoration: BoxDecoration(
            color: TrimeColors.surface,
            borderRadius: TrimeSpacing.radiusMd,
            border: Border.all(color: TrimeColors.surfaceAlt),
          ),
          child: Row(
            children: [
            Expanded(child: _legendDot(SlotStatus.tersedia)),
            Expanded(child: _legendDot(SlotStatus.penuh)),
            Expanded(child: _legendDot(SlotStatus.libur)),
          ],
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Tap slot untuk ubah status slot (default: libur semua)',
            style: TextStyle(
                color: TrimeColors.textMuted, fontSize: 11),
          ),
        ),
        const SizedBox(height: TrimeSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 54,
          ),
          itemCount: _slots.length,
          itemBuilder: (context, i) {
            final slot = _slots[i];
            final status = _slotStatus(_selectedDay, slot);
            return GestureDetector(
              onTap: () => _toggleSlot(_selectedDay, slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _slotColor(status),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _slotTextColor(status).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot,
                      style: GoogleFonts.poppins(
                        color: _slotTextColor(status),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _slotText(status),
                      style: TextStyle(
                        color: _slotTextColor(status),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: '📌 Tandai Hari Ini Libur Semua',
          onPressed: () {
            setState(() {
              for (final s in _slots) {
                _daySlots['$_selectedDay-$s'] = SlotStatus.libur;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('${_days[_selectedDay]} ditandai libur semua'),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            side: const BorderSide(color: TrimeColors.successGreen),
            foregroundColor: TrimeColors.successGreen,
          ),
          onPressed: () {
            setState(() {
              for (final s in _slots) {
                if (s.compareTo('09:00') >= 0 && s.compareTo('21:00') <= 0) {
                  _daySlots['$_selectedDay-$s'] = SlotStatus.tersedia;
                }
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('${_days[_selectedDay]}: semua slot tersedia'),
              ),
            );
          },
          child: const Text('Buka Semua Slot Hari Ini (09:00 - 21:00)'),
        ),
        const SizedBox(height: TrimeSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              await _persistSchedule();
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
                          'Jadwal berhasil disimpan!',
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

  Widget _legendDot(SlotStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _slotColor(status),
            shape: BoxShape.circle,
            border: Border.all(color: _slotTextColor(status),
                width: 1.2),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _slotText(status),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _slotTextColor(status)),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    if (_myBookings.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [
          _emptyHint(
            'Belum ada booking masuk.\n\nSabar ya, nanti pelanggan datang sendiri kok!',
            Icons.event_busy_outlined,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: TrimeSpacing.screenPadding,
      itemCount: _myBookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: TrimeSpacing.sm),
      itemBuilder: (context, i) {
        final b = _myBookings[i];
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
                          fontWeight: FontWeight.w700,
                          color: TrimeColors.primaryNavy)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(b.status)
                          .withValues(alpha: 0.12),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: TrimeColors.surfaceAlt,
                    child: b.customerName.isNotEmpty
                        ? Text(b.customerName.substring(0, 1),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: TrimeColors.primaryNavy))
                        : const Icon(Icons.person,
                            size: 18, color: TrimeColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.customerName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(b.serviceName,
                            style: TextStyle(
                                fontSize: 12,
                                color: TrimeColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(
                    _rupiah.format(b.price),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: TrimeColors.primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: TrimeColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID')
                        .format(b.date),
                    style: const TextStyle(
                        color: TrimeColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              if (b.status != 'done') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Hubungi WA',
                        mini: true,
                        prefixIcon: Icons.chat_outlined,
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('Membuka WhatsApp customer...')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (b.status == 'pending')
                      SizedBox(
                        height: 34,
                        width: 34,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: TrimeColors.successGreen,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            appState.updateBookingStatus(b.id, 'confirmed');
                          },
                          icon: const Icon(Icons.check, size: 18),
                        ),
                      )
                    else
                      SizedBox(
                        height: 34,
                        width: 34,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: TrimeColors.primaryNavy,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            appState.updateBookingStatus(b.id, 'done');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Booking selesai ✅'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    final todayBookings = _myBookings.where((b) => DateUtils.isSameDay(b.date, DateTime.now()) && b.status != 'done').toList();
    return ListView(
      padding: TrimeSpacing.screenPadding,
      children: [
        Container(
          padding: const EdgeInsets.all(TrimeSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.1),
                const Color(0xFF2E3A59).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: TrimeSpacing.radiusMd,
            border: Border.all(color: TrimeColors.primaryNavy.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TrimeColors.primaryNavy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: TrimeColors.primaryNavy,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengingat Aktif',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      'Aktifkan pengingat untuk bookingan baru & slot penuh',
                      style: TextStyle(
                          color: TrimeColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TrimeSpacing.lg),
        Text('Atur Notifikasi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: TrimeSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: TrimeColors.surface,
            borderRadius: TrimeSpacing.radiusMd,
            border: Border.all(color: TrimeColors.surfaceAlt),
          ),
          child: Column(
            children: [
              _reminderSwitch(
                title: 'Bookingan Baru Masuk',
                subtitle: 'Notifikasi saat customer booking',
                value: _reminderBooking,
                onChanged: (v) => setState(() => _reminderBooking = v),
                icon: Icons.event_available_outlined,
                color: TrimeColors.secondaryBlue,
              ),
              const Divider(height: 1),
              _reminderSwitch(
                title: 'Pengingat 15 Menit Sebelum',
                subtitle: 'Ingatkan sesaat sebelum jadwal',
                value: _reminder15min,
                onChanged: (v) => setState(() => _reminder15min = v),
                icon: Icons.timer_outlined,
                color: Colors.orange,
              ),
              const Divider(height: 1),
              _reminderSwitch(
                title: 'Pengingat 1 Jam Sebelum',
                subtitle: 'Ingatkan lebih awal',
                value: _reminder1jam,
                onChanged: (v) => setState(() => _reminder1jam = v),
                icon: Icons.schedule_send_outlined,
                color: TrimeColors.primaryNavy,
              ),
              const Divider(height: 1),
              _reminderSwitch(
                title: 'Notifikasi WhatsApp',
                subtitle: 'Kirim pesan WA otomatis',
                value: _whatsappNotif,
                onChanged: (v) => setState(() => _whatsappNotif = v),
                icon: Icons.chat_bubble_outline,
                color: TrimeColors.successGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: TrimeSpacing.lg),
        Text('Pengingat Hari Ini',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: TrimeSpacing.sm),
        if (todayBookings.isEmpty)
          _emptyHint(
            'Tidak ada pengingat hari ini.\n\nPeriksa tab Booking untuk melihat semua jadwal.',
            Icons.notifications_none_outlined,
          )
        else
          Container(
            decoration: BoxDecoration(
              color: TrimeColors.surface,
              borderRadius: TrimeSpacing.radiusMd,
              border: Border.all(color: TrimeColors.surfaceAlt),
            ),
            child: Column(
              children: todayBookings.asMap().entries.map((e) {
                final b = e.value;
                return Column(
                  children: [
                    _reminderItem(
                      icon: Icons.alarm,
                      time: DateFormat('HH:mm').format(b.date),
                      title: 'Booking ${b.id} - ${b.customerName}',
                      subtitle: b.serviceName,
                      color: b.status == 'pending' ? Colors.orange : TrimeColors.successGreen,
                      onTap: () {},
                    ),
                    if (e.key != todayBookings.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: TrimeSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              await _persistReminders();
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
                          'Pengaturan pengingat disimpan!',
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

  Widget _reminderSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TrimeSpacing.md, vertical: TrimeSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: TrimeColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: TrimeColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _reminderItem({
    required IconData icon,
    required String time,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 11, color: TrimeColors.textSecondary)),
      trailing: Text(time,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: TrimeColors.primaryNavy)),
    );
  }
}
