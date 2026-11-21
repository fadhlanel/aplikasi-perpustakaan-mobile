import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pustaka_digital/core/api_client.dart';
import 'package:pustaka_digital/core/app_theme.dart';
import 'package:pustaka_digital/core/network_service.dart';
import 'package:pustaka_digital/providers/auth_provider.dart';
import 'package:pustaka_digital/providers/buku_provider.dart';
import 'package:pustaka_digital/providers/config_provider.dart';
import 'package:pustaka_digital/providers/pengumuman_provider.dart';
import 'package:pustaka_digital/providers/pinjaman_provider.dart';
import 'package:pustaka_digital/screens/home_screen.dart';

http.Response _json(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  tearDown(() => ApiClient.testClient = null);

  testWidgets(
      'Beranda tidak blank saat ada peminjaman aktif (footer Wrap tanpa Flexible)',
      (tester) async {
    ApiClient.testClient = MockClient((req) async {
      final path = req.url.path;
      if (path.endsWith('/buku')) {
        return _json({
          'data': [],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
        });
      }
      if (path.endsWith('/kategori')) return _json({'data': []});
      if (path.endsWith('/pengumuman')) return _json({'data': []});
      if (path.endsWith('/peminjaman')) {
        return _json({
          'data': [
            {
              'id': 1,
              'trx_id': 'TRX-UJI-1',
              'nis': '000000',
              'nama_peminjam': 'Siswa Uji',
              'buku_id': 1,
              'judul_buku': 'Buku Uji',
              'tanggal_pinjam': '2026-11-20',
              'tanggal_jatuh_tempo': '2026-11-23',
              'status': 'dipinjam',
              'sisa_hari': 3,
            }
          ],
        });
      }
      if (path.endsWith('/config')) return _json({'data': {'status_layanan': 'aktif'}});
      return _json({'data': []});
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NetworkService()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => BukuProvider()),
          ChangeNotifierProvider(create: (_) => PengumumanProvider()),
          ChangeNotifierProvider(create: (_) => ConfigProvider()),
          ChangeNotifierProvider(create: (_) => PinjamanProvider()),
        ],
        child: MaterialApp(theme: AppTheme.build(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'kartu peminjaman aktif tidak boleh melempar error parent data');
    expect(find.textContaining('Dipinjam:'), findsOneWidget,
        reason: 'footer kartu peminjaman aktif harus tampil');
    expect(find.text('Kembalikan Buku'), findsOneWidget);
  });
}
