import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../core/services/app_state.dart';

enum JadwalTab { upcoming, history }

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DateFormat _dateFormatter = DateFormat('EEEE, d MMM yyyy', 'id_ID');
  final DateFormat _hourFormatter = DateFormat('HH:mm');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return TrimeColors.successGreen;
      case 'done':
        return TrimeColors.textMuted;
      case 'cancelled':
        return TrimeColors.dangerRed;
      default:
        return TrimeColors.textMuted;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'done':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return '-';
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':
        return Icons.hourglass_top;
      case 'confirmed':
        return Icons.check_circle;
      case 'done':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _cancelBooking(BookingItem booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text(
          'Batalkan Booking?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: const Text('Booking yang dibatalkan tidak dapat dikembalikan. Apakah Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: TrimeColors.dangerRed),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (result == true) {
      appState.cancelBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: TrimeColors.dangerRed,
            content: Text('Booking dibatalkan'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrimeColors.background,
      appBar: AppBar(
        title: Text(
          'Jadwal Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upcoming_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Akan Datang'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Riwayat'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(
            items: appState.upcomingBookings,
            emptyTitle: 'Belum ada booking',
            emptyIcon: Icons.calendar_month_outlined,
            emptySubtitle:
                'Booking kapster favoritmu dan jadwalkan potong rambut secara teratur',
            showCancel: true,
          ),
          _buildBookingList(
            items: appState.pastBookings,
            emptyTitle: 'Belum ada riwayat',
            emptyIcon: Icons.inbox_outlined,
            emptySubtitle: 'Semua bookingan yang selesai atau dibatalkan akan tampil di sini',
            showCancel: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList({
    required List<BookingItem> items,
    required String emptyTitle,
    required IconData emptyIcon,
    required String emptySubtitle,
    required bool showCancel,
  }) {
    if (items.isEmpty) {
      return ListView(
        padding: TrimeSpacing.screenPadding,
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: TrimeColors.surface,
              borderRadius: TrimeSpacing.radiusMd,
              border: Border.all(color: TrimeColors.surfaceAlt),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(emptyIcon, size: 64, color: TrimeColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TrimeColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TrimeColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: TrimeSpacing.screenPadding.copyWith(top: TrimeSpacing.md, bottom: TrimeSpacing.xxl * 2),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: TrimeSpacing.md),
      itemBuilder: (context, idx) {
        final b = items[idx];
        return _buildBookingCard(b, showCancel);
      },
    );
  }

  Widget _buildBookingCard(BookingItem b, bool showCancel) {
    final statusColor = _statusColor(b.status);
    return Card(
      elevation: TrimeSpacing.elevationCard,
      shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(TrimeSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: TrimeColors.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: TrimeSpacing.radiusSm,
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: TrimeColors.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: TrimeSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: TrimeColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (b.barbershopId.isNotEmpty) b.barbershopId,
                          if (b.kapsterName.isNotEmpty) b.kapsterName,
                        ].join(' • '),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TrimeColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: TrimeSpacing.radiusPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(b.status), size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusText(b.status),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: TrimeSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _infoTile(
                    icon: Icons.calendar_today_rounded,
                    label: _dateFormatter.format(b.date),
                  ),
                ),
                _infoTile(
                  icon: Icons.access_time_rounded,
                  label: _hourFormatter.format(b.date),
                ),
              ],
            ),
            const SizedBox(height: TrimeSpacing.sm),
            _infoTile(
              icon: Icons.payments_rounded,
              label: _currencyFormatter.format(b.price),
              labelColor: TrimeColors.primaryNavy,
              labelWeight: FontWeight.w700,
            ),
            if (b.notes != null && b.notes!.isNotEmpty) ...[
              const SizedBox(height: TrimeSpacing.sm),
              _infoTile(
                icon: Icons.notes_outlined,
                label: b.notes!,
              ),
            ],
            const SizedBox(height: TrimeSpacing.md),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    mini: true,
                    label: 'Lihat Detail',
                    prefixIcon: Icons.visibility_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ID Booking: ${b.id}'),
                        ),
                      );
                    },
                  ),
                ),
                if (showCancel &&
                    (b.status == 'pending' ||
                        b.status == 'confirmed')) ...[
                  const SizedBox(width: TrimeSpacing.sm),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(b),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TrimeColors.dangerRed,
                        side: const BorderSide(color: TrimeColors.dangerRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    Color? labelColor,
    FontWeight labelWeight = FontWeight.w500,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: TrimeColors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: labelWeight,
              color: labelColor ?? TrimeColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
