import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anodor/core/app_theme.dart';
import 'package:anodor/providers/auth_provider.dart';
import 'package:anodor/providers/buku_provider.dart';
import 'package:anodor/providers/pinjaman_provider.dart';
import 'package:anodor/screens/detail_buku_screen.dart';
import 'package:anodor/screens/home_screen.dart';
import 'package:anodor/screens/login_screen.dart';
import 'package:anodor/screens/pinjaman_screen.dart';
import 'package:anodor/screens/profil_screen.dart';
import 'package:anodor/screens/splash_screen.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => BukuProvider()),
      ChangeNotifierProvider(create: (_) => PinjamanProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.build(),
      home: child,
    ),
  );
}

void main() {
  testWidgets('Layar 1: Splash screen menampilkan judul Pustaka Digital & SMK 1 Surabaya', (tester) async {
    await tester.pumpWidget(createTestApp(const SplashScreen()));

    expect(find.text('Pustaka Digital'), findsOneWidget);
    expect(find.text('Sistem Perpustakaan Pintar SMK / SMA'), findsOneWidget);
    expect(find.text('SMK Negeri 1 Surabaya  •'), findsOneWidget);
  });

  testWidgets('Layar 2: Login screen menampilkan form NIS, PIN, dan tombol Masuk', (tester) async {
    await tester.pumpWidget(createTestApp(const LoginScreen()));

    expect(find.text('Login atau Daftar!'), findsOneWidget);
    expect(find.text('NIS / ID Anggota'), findsOneWidget);
    expect(find.text('Password / PIN Perpustakaan'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Layar 3: Home screen menampilkan sapaan siswa, status pinjaman, & kategori', (tester) async {
    await tester.pumpWidget(createTestApp(const HomeScreen()));

    expect(find.text('PUSTAKADIGITAL'), findsOneWidget);
    expect(find.text('STATUS PEMINJAMAN ANDA'), findsOneWidget);
    expect(find.text('Kategori Buku'), findsOneWidget);
    expect(find.text('Rekomendasi Terpopuler'), findsOneWidget);
  });

  testWidgets('Layar 4: Detail buku screen menampilkan ketersediaan, lokasi rak, & reservasi', (tester) async {
    await tester.pumpWidget(createTestApp(const DetailBukuScreen(bukuId: 1)));

    expect(find.text('Detail Buku'), findsOneWidget);
    expect(find.text('Sinopsis & Ringkasan'), findsOneWidget);
    expect(find.text('Tanya Pustakawan'), findsOneWidget);
    expect(find.text('Reservasi Pinjam'), findsOneWidget);
  });

  testWidgets('Layar 5: Pinjaman screen menampilkan kebijakan, filter tabs, & perpanjangan', (tester) async {
    await tester.pumpWidget(createTestApp(const PinjamanScreen()));

    expect(find.text('Pinjaman Saya'), findsOneWidget);
    expect(find.text('Kebijakan'), findsOneWidget);
    expect(find.text('Sedang Dipinjam'), findsOneWidget);
    expect(find.text('Ajukan Perpanjangan Waktu (+7 Hari)'), findsOneWidget);
  });

  testWidgets('Layar 6: Profil screen menampilkan identitas siswa, 3 statistik, & keluar akun', (tester) async {
    await tester.pumpWidget(createTestApp(const ProfilScreen()));

    expect(find.text('Profil Siswa'), findsOneWidget);
    expect(find.text('ANGGOTA TERVERIFIKASI'), findsOneWidget);
    expect(find.text('Keluar Akun'), findsOneWidget);
  });
}
