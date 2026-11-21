import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pustaka_digital/core/api_client.dart';
import 'package:pustaka_digital/providers/pengumuman_provider.dart';

http.Response _json(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  tearDown(() => ApiClient.testClient = null);

  test('Pengumuman kosong: loading kembali false dan notify terkirim', () async {
    ApiClient.testClient = MockClient((_) async => _json({'data': []}));

    final provider = PengumumanProvider();
    final notifies = <String>[];
    provider.addListener(() => notifies.add('loading=${provider.loading}'));

    await provider.load();

    expect(provider.loading, isFalse);
    expect(notifies.length, greaterThanOrEqualTo(2));
  });

  test('Pengumuman gagal jaringan + cache kosong: loading kembali false', () async {
    ApiClient.testClient =
        MockClient((_) async => throw const SocketException('offline'));

    final provider = PengumumanProvider();
    await provider.load();

    expect(provider.loading, isFalse);
  });
}
