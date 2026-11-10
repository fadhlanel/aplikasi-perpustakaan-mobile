import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// URL dasar API yang dapat dioverride lewat --dart-define=BASE_URL=...
/// Default dipilih otomatis berdasarkan platform:
/// - Web (Chrome): http://127.0.0.1:8000/api/v1
/// - Emulator Android: http://10.0.2.2:8000/api/v1 (localhost bengkomputer host)
/// - HP fisik: set BASE_URL ke IP LAN laptop, contoh http://192.168.1.5:8000/api/v1
const _envBaseUrl = String.fromEnvironment('BASE_URL');

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  ApiClient._();

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    return 'http://10.0.2.2:8000/api/v1';
  }

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Panggil GET dan kembalikan body JSON berbentuk Map.
  /// Membuang ApiException bila gagal koneksi/salah format.
  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...query,
      });
    }
    try {
      final res = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );
      return _parse(res);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghubungi server. Pastikan "php artisan serve" berjalan di backend.\n$e');
    }
  }

  /// Panggil POST dan kembalikan body JSON berbentuk Map.
  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 10));
      return _parse(res);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghubungi server.\n$e');
    }
  }

  static Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode >= 500) {
      throw ApiException('Kesalahan server (${res.statusCode}).');
    }
    try {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Format respons tidak valid (${res.statusCode}).');
    }
  }
}
