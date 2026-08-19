import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/pages/splash_page.dart';
import 'core/services/auth_service.dart';
import 'core/services/app_state.dart';
import 'core/services/supabase_service.dart';
import 'core/services/backend_service.dart';
import 'theme/app_theme.dart';

final AuthService authService = AuthService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error (periksa google-services.json): $e');
  }
  await backendService.init();
  await supabaseService.init();
  await appState.loadAll();
  runApp(const TrimeApp());
}

class TrimeApp extends StatelessWidget {
  const TrimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRIME',
      debugShowCheckedModeBanner: false,
      theme: TrimeTheme.build(),
      home: SplashPage(authService: authService),
    );
  }
}
