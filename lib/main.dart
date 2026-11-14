import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/network_service.dart';
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/config_provider.dart';
import 'providers/pengumuman_provider.dart';
import 'providers/pinjaman_provider.dart';
import 'providers/riwayat_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.init();
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
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
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
