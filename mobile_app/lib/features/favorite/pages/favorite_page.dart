import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/card_barbershop.dart';
import '../../../shared_widgets/card_kapster.dart';
import '../../../shared_widgets/bottom_nav_bar.dart';
import '../../../core/services/app_state.dart';
import '../../booking/pages/booking_calendar_page.dart';
import '../../home/pages/barbershop_detail_page.dart';

enum FavTab { barbershop, kapster }

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Barbershop> get _allBarbershops {
    return appState.barbershops.map((p) {
      return Barbershop(
        name: p.name,
        distanceKm: 0.0,
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

  void _navigateBooking({Barbershop? b, Kapster? k}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingCalendarPage(initialBarbershop: b, initialKapster: k),
      ),
    );
  }

  void _navigateBarbershopDetail(Barbershop b) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BarbershopDetailPage(barbershop: b)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrimeColors.background,
      appBar: AppBar(
        title: Text(
          'Favorit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Barbershop'),
            Tab(text: 'Kapster'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBarbershopGrid(),
          _buildKapsterList(),
        ],
      ),
    );
  }

  Widget _buildBarbershopGrid() {
    final List<Barbershop> favs = appState.filterFavoriteBarbershops(_allBarbershops);
    if (favs.isEmpty) {
      return const PlaceholderScreen(
        title: 'Belum ada barbershop favorit',
        icon: Icons.storefront_outlined,
        subtitle: 'Tap ikon hati pada barbershop untuk menyimpannya di sini',
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: TrimeSpacing.md,
      mainAxisSpacing: TrimeSpacing.md,
      childAspectRatio: 0.62,
      padding: TrimeSpacing.screenPadding.copyWith(top: TrimeSpacing.md, bottom: TrimeSpacing.xxl * 2),
      children: favs.map((b) {
        return CardBarbershop(
          barbershop: b,
          isFavorite: true,
          onTap: () => _navigateBarbershopDetail(b),
          onBook: () => _navigateBooking(b: b),
          onFavorite: () => appState.toggleFavoriteBarbershop(b.name),
        );
      }).toList(),
    );
  }

  Widget _buildKapsterList() {
    final List<Kapster> favs = appState.filterFavoriteKapsters(_allKapsters);
    if (favs.isEmpty) {
      return const PlaceholderScreen(
        title: 'Belum ada kapster favorit',
        icon: Icons.content_cut,
        subtitle: 'Simpan kapster favoritmu agar booking lebih cepat',
      );
    }
    return ListView.separated(
      padding: TrimeSpacing.screenPadding.copyWith(top: TrimeSpacing.md, bottom: TrimeSpacing.xxl * 2),
      itemCount: favs.length,
      separatorBuilder: (_, _) => const SizedBox(height: TrimeSpacing.md),
      itemBuilder: (_, idx) {
        final k = favs[idx];
        return CardKapster(
          kapster: k,
          onTap: () => _navigateBooking(k: k),
        );
      },
    );
  }
}
