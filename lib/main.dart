import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/pinjaman_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnodorApp());
}

class AnodorApp extends StatelessWidget {
  const AnodorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BukuProvider()),
        ChangeNotifierProvider(create: (_) => PinjamanProvider()),
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
