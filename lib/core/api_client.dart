import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Base URL terpusat. Override saat build:
///   --dart-define=API_BASE_URL=https://SERVICE-URL.a.run.app/api/v1
///
/// Nama lama `BASE_URL` tetap dibaca agar perintah build/dokumentasi lama tidak
/// langsung rusak.
const _envBaseUrl = String.fromEnvironment('API_BASE_URL');
const _legacyBaseUrl = String.fromEnvironment('BASE_URL');

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
    this.errors,
  });

  final String message;
  final int? statusCode;

  /// True hanya bila server tidak dapat dihubungi / timeout.
  /// Error HTTP (400/401/403/404/422/429/500) bernilai false.
  final bool isNetworkError;

  final Map<String, dynamic>? errors;

  @override
  String toString() => 'ApiException(${statusCode ?? 'network'}): $message';
}

class ApiClient {
  ApiClient._();

  static const Duration timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (_legacyBaseUrl.isNotEmpty) return _legacyBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// Proyek belum memakai autentikasi token; backend tidak punya Sanctum.
  /// Sisipkan header Authorization di sini bila nanti ditambahkan.
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

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
    return _send(() => http.get(uri, headers: _headers));
  }

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () => http.post(uri, headers: _headers, body: jsonEncode(body ?? {})),
    );
  }

  static Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    http.Response res;
    try {
      res = await request().timeout(timeout);
    } on TimeoutException {
      throw ApiException(
        'Server tidak merespons dalam ${timeout.inSeconds} detik.',
        isNetworkError: true,
      );
    } catch (e) {
      throw ApiException(
        'Gagal menghubungi server ($baseUrl). Periksa koneksi internet.',
        isNetworkError: true,
      );
    }
    return _parse(res);
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      body = null;
    }

    if (ok) {
      return body ?? <String, dynamic>{};
    }

    final message = body?['message'] as String? ?? _defaultMessage(res.statusCode);
    final errors = body?['errors'];
    throw ApiException(
      message,
      statusCode: res.statusCode,
      errors: errors is Map<String, dynamic> ? errors : null,
    );
  }

  static String _defaultMessage(int code) {
    switch (code) {
      case 400:
        return 'Permintaan tidak dapat diproses.';
      case 401:
        return 'Sesi tidak valid. Silakan masuk kembali.';
      case 403:
        return 'Anda tidak memiliki akses.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 429:
        return 'Terlalu banyak permintaan. Coba lagi sebentar.';
      case >= 500:
        return 'Kesalahan server ($code).';
      default:
        return 'Permintaan gagal ($code).';
    }
  }
}
