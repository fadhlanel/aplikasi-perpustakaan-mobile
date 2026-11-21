import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pustaka_digital/core/api_client.dart';
import 'package:pustaka_digital/core/app_theme.dart';
import 'package:pustaka_digital/models/buku.dart';
import 'package:pustaka_digital/models/peminjaman.dart';
import 'package:pustaka_digital/providers/buku_provider.dart';
import 'package:pustaka_digital/providers/pinjaman_provider.dart';
import 'package:pustaka_digital/screens/pinjaman_screen.dart';

http.Response _jsonResponse(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

Buku _buku(int id, String judul) => Buku(
      id: id,
      judul: judul,
      tahunTerbit: 2024,
      stok: 2,
      stokTersedia: 1,
    );

Map<String, dynamic> _pinjaman({
  required int id,
  required String status,
  String? statusReservasi,
}) =>
    {
      'id': id,
      'trx_id': 'TRX-$id',
      'nis': '000000',
      'nama_peminjam': 'Siswa Uji',
      'buku_id': 1,
      'judul_buku': 'Buku Uji $id',
      'tanggal_pinjam': '01 Nov 2026',
      'tanggal_jatuh_tempo': '04 Nov 2026',
      'status': status,
      if (statusReservasi != null) 'status_reservasi': statusReservasi,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  tearDown(() => ApiClient.testClient = null);

  test('refresh katalog mempertahankan data lama sampai respons baru tiba', () async {
    final gate = Completer<http.Response>();
    ApiClient.testClient = MockClient((_) => gate.future);

    final provider = BukuProvider();
    final lama = _buku(1, 'Buku Lama');
    provider.items = [lama];
    provider.popularBooks = [lama];
    provider.latestBooks = [lama];

    final refresh = provider.loadFirst();
    await Future<void>.delayed(Duration.zero);

    expect(provider.loading, isFalse, reason: 'refresh harus silent saat data sudah ada');
    expect(provider.popularBooks.single.judul, 'Buku Lama');

    gate.complete(_jsonResponse({
      'data': [
        {
          'id': 2,
          'judul': 'Buku Baru',
          'tahun_terbit': 2026,
          'stok': 1,
          'stok_tersedia': 1,
        }
      ],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
    }));
    await refresh;

    expect(provider.popularBooks.single.judul, 'Buku Baru');
  });

  test('gagal refresh katalog tidak menimpa data yang sedang tampil', () async {
    ApiClient.testClient = MockClient((_) async => throw SocketException('offline'));

    final provider = BukuProvider();
    final lama = _buku(1, 'Buku Lama');
    provider.items = [lama];
    provider.popularBooks = [lama];
    provider.latestBooks = [lama];

    await provider.loadFirst();

    expect(provider.popularBooks.single.judul, 'Buku Lama');
    expect(provider.loading, isFalse);
  });

  test('polling peminjaman tidak mengosongkan daftar sebelum respons tiba', () async {
    final gate = Completer<http.Response>();
    ApiClient.testClient = MockClient((_) => gate.future);

    final provider = PinjamanProvider();
    final lama = Peminjaman.fromJson(_pinjaman(id: 1, status: 'booking', statusReservasi: 'booking'));
    provider.activeLoans = [lama];
    provider.historyLoans = [];

    final refresh = provider.fetchApiLoans();
    await Future<void>.delayed(Duration.zero);

    expect(provider.activeLoans, hasLength(1));

    gate.complete(_jsonResponse({'data': []}));
    await refresh;

    expect(provider.activeLoans, isEmpty);
    provider.dispose();
  });

  testWidgets('Riwayat Selesai membedakan batal, kedaluwarsa, dan dikembalikan', (tester) async {
    final riwayat = [
      _pinjaman(id: 1, status: 'dibatalkan', statusReservasi: 'dibatalkan'),
      _pinjaman(id: 2, status: 'dibatalkan', statusReservasi: 'expired'),
      _pinjaman(id: 3, status: 'dikembalikan'),
    ];
    ApiClient.testClient = MockClient((_) async => _jsonResponse({'data': riwayat}));

    final provider = PinjamanProvider();
    provider.setTab(1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<PinjamanProvider>.value(value: provider)],
        child: MaterialApp(theme: AppTheme.build(), home: const PinjamanScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reservasi Dibatalkan'), findsOneWidget);
    expect(find.text('Reservasi Kedaluwarsa'), findsOneWidget);
    expect(find.text('Dikembalikan'), findsOneWidget);
    expect(find.textContaining('Dikembalikan tepat waktu'), findsOneWidget);
    expect(find.textContaining('stok dikembalikan otomatis'), findsNWidgets(2));
    expect(find.text('Beri rating'), findsOneWidget);

    provider.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}