import 'package:flutter/material.dart';
import '../shared_widgets/bottom_nav_bar.dart';
import 'home/pages/home_page.dart';
import 'booking/pages/jadwal_page.dart';
import 'favorite/pages/favorite_page.dart';
import 'auth/pages/akun_page.dart';
import 'home/pages/barber_dashboard_page.dart';
import 'home/pages/kapster_dashboard_page.dart';
import '../core/services/auth_service.dart';
import '../../main.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = authService.currentUser?.role ?? UserRole.pelanggan;

    final List<Widget> pages;
    if (role == UserRole.mitra) {
      pages = [
        const BarberDashboardPage(),
        AkunPage(authService: authService),
      ];
    } else if (role == UserRole.kapster) {
      pages = [
        const KapsterDashboardPage(),
        AkunPage(authService: authService),
      ];
    } else {
      pages = [
        const HomePage(),
        const JadwalPage(),
        const FavoritePage(),
        AkunPage(authService: authService),
      ];
    }

    final index = _currentIndex >= pages.length ? 0 : _currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        onTap: (i) => setState(() => _currentIndex = i),
        role: role,
      ),
    );
  }
}
