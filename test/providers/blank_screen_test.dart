import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pustaka_digital/core/api_client.dart';
import 'package:pustaka_digital/providers/buku_provider.dart';

http.Response _json(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  tearDown(() => ApiClient.testClient = null);

  test('API buku kosong: loading harus kembali false dan notify terkirim', () async {
    ApiClient.testClient = MockClient((_) async => _json({
          'data': [],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
        }));

    final provider = BukuProvider();
    final notifies = <String>[];
    provider.addListener(() => notifies.add('loading=${provider.loading}|items=${provider.items.length}'));

    await provider.loadFirst();

    expect(provider.loading, isFalse,
        reason: 'loading harus false setelah API sukses walau data kosong');
    expect(notifies.length, greaterThanOrEqualTo(2),
        reason: 'harus ada notify untuk loading=true lalu loading=false');
  });

  test('API buku gagal + cache kosong: loading harus kembali false', () async {
    ApiClient.testClient =
        MockClient((_) async => throw const SocketException('offline'));

    final provider = BukuProvider();
    await provider.loadFirst();

    expect(provider.loading, isFalse,
        reason: 'loading tidak boleh macet true saat gagal dan cache kosong');
    expect(provider.error, isNotNull);
  });
}
