import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/network_service.dart';
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/pengumuman_provider.dart';
import 'providers/pinjaman_provider.dart';
import 'providers/riwayat_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PustakaDigitalApp());
}

class PustakaDigitalApp extends StatelessWidget {
  const PustakaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BukuProvider()),
        ChangeNotifierProvider(create: (_) => PengumumanProvider()),
        ChangeNotifierProvider(create: (_) => PinjamanProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
      ],
      child: MaterialApp(
        title: 'Pustaka Digital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashScreen(),
      ),
    );
  }
}
