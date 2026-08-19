import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/card_barbershop.dart';
import '../../../shared_widgets/card_kapster.dart';
import '../../../core/services/app_state.dart';

class BookingCalendarPage extends StatefulWidget {
  final Barbershop? initialBarbershop;
  final Kapster? initialKapster;

  const BookingCalendarPage({
    super.key,
    this.initialBarbershop,
    this.initialKapster,
  });

  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  DateTime? _selectedSlotStart;
  final DateFormat _dayFormatter = DateFormat('E', 'id_ID');
  final DateFormat _dateFormatter = DateFormat('d');
  final DateFormat _monthFormatter = DateFormat('MMMM yyyy', 'id_ID');
  final DateFormat _hourFormatter = DateFormat('HH:mm');
  final DateFormat _fullDateFormatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _serviceOptions = const [
    {'name': 'Potong Rambut Reguler', 'price': 75000.0, 'duration': 45},
    {'name': 'Potong Rambut + Cuci', 'price': 100000.0, 'duration': 60},
    {'name': 'Fade Master Cut', 'price': 125000.0, 'duration': 75},
    {'name': 'Pompadour Styling', 'price': 150000.0, 'duration': 90},
    {'name': 'Smoothing / Creambath', 'price': 200000.0, 'duration': 120},
  ];
  int _selectedServiceIdx = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<DateTime> _getWeekDays(DateTime focused) {
    final monday = focused.subtract(Duration(days: focused.weekday - 1));
    return List.generate(7, (idx) => monday.add(Duration(days: idx)));
  }

  void _prevWeek() {
    setState(() {
      _focusedDate = _focusedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _focusedDate = _focusedDate.add(const Duration(days: 7));
    });
  }

  Future<void> _submitBooking() async {
    if (_selectedSlotStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih slot waktu terlebih dahulu')),
      );
      return;
    }

    final service = _serviceOptions[_selectedServiceIdx];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: TrimeSpacing.radiusLg),
        title: Text(
          'Konfirmasi Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.initialBarbershop != null)
              Text('📌 ${widget.initialBarbershop!.name}'),
            if (widget.initialKapster != null) Text('💈 ${widget.initialKapster!.nama}'),
            const SizedBox(height: TrimeSpacing.sm),
            Text('📅 ${_fullDateFormatter.format(_selectedSlotStart!)}'),
            Text('⏰ ${_hourFormatter.format(_selectedSlotStart!)}'),
            const SizedBox(height: TrimeSpacing.sm),
            Text('✂️ ${service['name']}'),
            Text(
              '💰 Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(service['price'])}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TrimeColors.primaryNavy,
            ),
            child: const Text('Ya, Booking'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final bookingId = appState.addBooking(
      barbershop: widget.initialBarbershop,
      kapster: widget.initialKapster,
      dateTime: _selectedSlotStart!,
      serviceName: service['name'] as String,
      price: service['price'] as double,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TrimeColors.successGreen,
        content: Text('✅ Booking berhasil dibuat! ID: $bookingId'),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_focusedDate);
    final slots = appState.generateAvailabilitySlots(_selectedDate);
    final selectedService = _serviceOptions[_selectedServiceIdx];

    return Scaffold(
      backgroundColor: TrimeColors.background,
      appBar: AppBar(
        title: Text(
          widget.initialBarbershop != null || widget.initialKapster != null
              ? 'Booking Sekarang'
              : 'Booking Kalender',
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TrimeSpacing.lg,
          0,
          TrimeSpacing.lg,
          TrimeSpacing.xl * 2,
        ),
        children: [
          if (widget.initialBarbershop != null)
            Padding(
              padding: const EdgeInsets.only(bottom: TrimeSpacing.md),
              child: CardBarbershop(barbershop: widget.initialBarbershop!),
            ),
          if (widget.initialKapster != null)
            Padding(
              padding: const EdgeInsets.only(bottom: TrimeSpacing.md),
              child: CardKapster(kapster: widget.initialKapster!),
            ),
          _buildMonthHeader(),
          const SizedBox(height: TrimeSpacing.md),
          _buildWeekStrip(weekDays),
          const SizedBox(height: TrimeSpacing.xl),
          Text(
            'Pilih Waktu',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: TrimeSpacing.sm),
          _buildTimeSlots(slots),
          const SizedBox(height: TrimeSpacing.xl),
          Text(
            'Pilih Layanan',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: TrimeSpacing.sm),
          _buildServiceList(),
          const SizedBox(height: TrimeSpacing.xl),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Catatan tambahan (opsional)',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: TrimeSpacing.xl),
          _buildPriceSummary(selectedService),
          const SizedBox(height: TrimeSpacing.lg),
          PrimaryButton(
            label: _selectedSlotStart == null ? 'Pilih slot waktu' : 'Konfirmasi Booking',
            prefixIcon: _selectedSlotStart == null ? Icons.schedule : Icons.check_circle,
            onPressed: _selectedSlotStart == null ? null : _submitBooking,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: _prevWeek,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: TrimeColors.surfaceAlt,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              _monthFormatter.format(_focusedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: _nextWeek,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: TrimeColors.surfaceAlt,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekStrip(List<DateTime> weekDays) {
    return Container(
      padding: const EdgeInsets.all(TrimeSpacing.sm),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        boxShadow: [
          BoxShadow(
            color: TrimeColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((date) {
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isPast = date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
          final isToday =
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return GestureDetector(
            onTap: isPast
                ? null
                : () => setState(() {
                      _selectedDate = DateTime(date.year, date.month, date.day);
                      _selectedSlotStart = null;
                    }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: TrimeSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? TrimeColors.primaryNavy : Colors.transparent,
                borderRadius: TrimeSpacing.radiusSm,
              ),
              child: Column(
                children: [
                  Text(
                    _dayFormatter.format(date).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? TrimeColors.textMuted
                              : TrimeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday && !isSelected
                          ? TrimeColors.secondaryBlue.withValues(alpha: 0.15)
                          : Colors.transparent,
                    ),
                    child: Text(
                      _dateFormatter.format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : isPast
                                ? TrimeColors.textMuted
                                : isToday
                                    ? TrimeColors.secondaryBlue
                                    : TrimeColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlots(List<AvailabilitySlot> slots) {
    final now = DateTime.now();
    return Wrap(
      spacing: TrimeSpacing.sm,
      runSpacing: TrimeSpacing.sm,
      children: slots.map((slot) {
        final DateTime slotStart = slot.start;
        final slotDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          slotStart.hour,
          slotStart.minute,
        );
        final isPast = slotDateTime.isBefore(now);

        final isSelected = _selectedSlotStart != null &&
            slotStart.hour == _selectedSlotStart!.hour &&
            slotStart.minute == _selectedSlotStart!.minute &&
            slotStart.year == _selectedDate.year &&
            slotStart.month == _selectedDate.month &&
            slotStart.day == _selectedDate.day;

        final enabled = slot.isAvailable && !isPast;

        return GestureDetector(
          onTap: enabled
              ? () => setState(() {
                    _selectedSlotStart = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      slotStart.hour,
                      slotStart.minute,
                    );
                  })
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: TrimeSpacing.md,
              vertical: TrimeSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? TrimeColors.primaryNavy
                  : enabled
                      ? TrimeColors.surface
                      : TrimeColors.surfaceAlt,
              borderRadius: TrimeSpacing.radiusSm,
              border: Border.all(
                color: isSelected
                    ? TrimeColors.primaryNavy
                    : enabled
                        ? TrimeColors.surfaceAlt
                        : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hourFormatter.format(slotStart),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : enabled
                            ? TrimeColors.textPrimary
                            : TrimeColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                if (!slot.isAvailable)
                  Text(
                    'Terisi',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: TrimeColors.dangerRed,
                    ),
                  )
                else if (isPast && !isSelected)
                  Text(
                    'Lewat',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: TrimeColors.textMuted,
                    ),
                  )
                else
                  Text(
                    'Tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : TrimeColors.successGreen,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceList() {
    return Column(
      children: _serviceOptions.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final selected = idx == _selectedServiceIdx;
        return Padding(
          padding: const EdgeInsets.only(bottom: TrimeSpacing.sm),
          child: GestureDetector(
            onTap: () => setState(() => _selectedServiceIdx = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(TrimeSpacing.md),
              decoration: BoxDecoration(
                color: selected
                    ? TrimeColors.primaryNavy.withValues(alpha: 0.06)
                    : TrimeColors.surface,
                borderRadius: TrimeSpacing.radiusMd,
                border: Border.all(
                  color: selected ? TrimeColors.primaryNavy : TrimeColors.surfaceAlt,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? TrimeColors.primaryNavy
                          : TrimeColors.surfaceAlt,
                      borderRadius: TrimeSpacing.radiusSm,
                    ),
                    child: Icon(
                      Icons.content_cut,
                      size: 20,
                      color: selected ? Colors.white : TrimeColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: TrimeSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: TrimeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⏱️ ${item['duration']} menit',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: TrimeColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item['price'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? TrimeColors.primaryNavy : TrimeColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSummary(Map<String, dynamic> service) {
    return Container(
      padding: const EdgeInsets.all(TrimeSpacing.md),
      decoration: BoxDecoration(
        color: TrimeColors.surface,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service['name'] as String,
                style: GoogleFonts.poppins(color: TrimeColors.textSecondary),
              ),
              Text(
                'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(service['price'])}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: TrimeSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya Layanan',
                style: GoogleFonts.poppins(color: TrimeColors.textSecondary),
              ),
              Text(
                'Termasuk',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: TrimeColors.successGreen,
                ),
              ),
            ],
          ),
          const Divider(height: TrimeSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(service['price'])}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: TrimeColors.primaryNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
