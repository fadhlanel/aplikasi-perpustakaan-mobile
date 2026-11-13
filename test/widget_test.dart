import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pustaka_digital/core/app_theme.dart';
import 'package:pustaka_digital/core/network_service.dart';
import 'package:pustaka_digital/models/pengumuman.dart';
import 'package:pustaka_digital/providers/auth_provider.dart';
import 'package:pustaka_digital/providers/buku_provider.dart';
import 'package:pustaka_digital/providers/config_provider.dart';
import 'package:pustaka_digital/providers/pengumuman_provider.dart';
import 'package:pustaka_digital/providers/pinjaman_provider.dart';
import 'package:pustaka_digital/screens/detail_buku_screen.dart';
import 'package:pustaka_digital/screens/home_screen.dart';
import 'package:pustaka_digital/screens/login_screen.dart';
import 'package:pustaka_digital/screens/pinjaman_screen.dart';
import 'package:pustaka_digital/screens/profil_screen.dart';
import 'package:pustaka_digital/screens/splash_screen.dart';
import 'package:pustaka_digital/widgets/api_status_badge.dart';
import 'package:pustaka_digital/widgets/pengumuman_section.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NetworkService()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => BukuProvider()),
      ChangeNotifierProvider(create: (_) => ConfigProvider()),
      ChangeNotifierProvider(create: (_) => PengumumanProvider()),
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
    expect(find.text('SMK Negeri 1 Surabaya'), findsOneWidget);
  });

  testWidgets('Layar 2: Login screen menampilkan form NIS, PIN, dan tombol Masuk tanpa masuk cepat', (tester) async {
    await tester.pumpWidget(createTestApp(const LoginScreen()));

    expect(find.text('Selamat Datang Kembali!'), findsOneWidget);
    expect(find.text('Login Siswa'), findsOneWidget);
    expect(find.text('Nomor Induk Siswa (NIS)'), findsOneWidget);
    expect(find.text('Password / PIN Keanggotaan'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Ingat Saya'), findsOneWidget);
    // Fitur masuk cepat sudah dihilangkan, tidak boleh ada lagi.
    expect(find.textContaining('Masuk Cepat'), findsNothing);
  });

  testWidgets('Layar 3: Home screen menampilkan sapaan siswa, status pinjaman, & kategori', (tester) async {
    await tester.pumpWidget(createTestApp(const HomeScreen()));

    expect(find.text('PUSTAKADIGITAL'), findsOneWidget);
    // Tanpa data dummy: tidak ada kartu peminjaman dummy.
    expect(find.text('STATUS PEMINJAMAN ANDA'), findsNothing);
    expect(find.text('Kategori Buku'), findsOneWidget);
    expect(find.text('Rekomendasi Terpopuler'), findsOneWidget);
    // Badge status koneksi REST API tampil di header beranda.
    expect(find.byType(ApiStatusBadge), findsOneWidget);
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
    // Tanpa data dummy: tidak ada tombol perpanjangan untuk pinjaman dummy.
    expect(find.text('Ajukan Perpanjangan Waktu (+1 Hari)'), findsNothing);
  });

  testWidgets('Layar 6: Profil screen menampilkan identitas siswa, 3 statistik, menu aktivitas & keluar akun', (tester) async {
    await tester.pumpWidget(createTestApp(const ProfilScreen()));

    expect(find.text('Profil Siswa'), findsOneWidget);
    expect(find.text('Buku Favorit & Bookmark'), findsOneWidget);
    expect(find.text('Pengaturan Tema & Akun'), findsOneWidget);
    expect(find.text('Keluar Akun'), findsOneWidget);
  });

  testWidgets('Section pengumuman menampilkan state memuat, kosong, error, & offline', (tester) async {
    final prov = PengumumanProvider();
    Widget view() => ChangeNotifierProvider<PengumumanProvider>.value(
          value: prov,
          child: MaterialApp(
            theme: AppTheme.build(),
            home: Scaffold(
              body: PengumumanSection(
                key: ValueKey(
                    '${prov.loading}|${prov.items.length}|${prov.error}|${prov.offline}'),
              ),
            ),
          ),
        );

    prov.loading = true;
    await tester.pumpWidget(view());
    expect(find.text('Memuat pengumuman'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    prov.loading = false;
    await tester.pumpWidget(view());
    expect(find.text('Belum ada pengumuman'), findsOneWidget);

    prov.error = 'Data tidak ditemukan.';
    await tester.pumpWidget(view());
    expect(find.text('Pengumuman gagal dimuat'), findsOneWidget);
    expect(find.text('Data tidak ditemukan.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);

    prov.error = null;
    prov.offline = true;
    prov.items = [
      const Pengumuman(id: 1, judul: 'Jam layanan', isi: 'Perpustakaan buka 07.00-15.00.'),
    ];
    await tester.pumpWidget(view());
    expect(find.text('Mode offline'), findsOneWidget);
    expect(find.text('Jam layanan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
