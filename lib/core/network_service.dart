import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'offline_cache.dart';

enum ConnectionStatus {
  unknown, // Masih memeriksa status saat aplikasi dibuka
  connected, // Terhubung ke REST API
  apiOffline, // Terhubung ke internet, namun server API tidak dapat dijangkau
  noInternet, // Tidak ada koneksi internet sama sekali
}

class NetworkService extends ChangeNotifier with WidgetsBindingObserver {
  NetworkService() {
    WidgetsBinding.instance.addObserver(this);
    _loadLastSync();
    checkConnection();
    _startPeriodicCheck();
  }

  /// Interval pengecekan otomatis ke API.
  static const Duration checkInterval = Duration(seconds: 15);

  static const Duration _probeTimeout = Duration(seconds: 8);

  Timer? _timer;
  ConnectionStatus _status = ConnectionStatus.unknown;
  DateTime? _lastSyncTime;
  bool _isChecking = false;
  String? _lastError;
  DateTime? _lastChecked;

  ConnectionStatus get status => _status;
  bool get isChecking => _isChecking;
  String? get lastError => _lastError;
  DateTime? get lastChecked => _lastChecked;

  bool get isConnectedToApi => _status == ConnectionStatus.connected;
  bool get isApiOffline => _status == ConnectionStatus.apiOffline;
  bool get hasNoInternet => _status == ConnectionStatus.noInternet;

  String get statusText {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'API Terhubung';
      case ConnectionStatus.apiOffline:
        return 'Mode Offline (Data Terakhir)';
      case ConnectionStatus.noInternet:
        return 'Tidak Ada Koneksi Internet';
      case ConnectionStatus.unknown:
        return 'Memeriksa...';
    }
  }

  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> _loadLastSync() async {
    _lastSyncTime = await OfflineCache.getLastSyncTime();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkConnection();
      _startPeriodicCheck();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) {
      if (!_isChecking) {
        checkConnection();
      }
    });
  }

  /// URL health check backend. `/api` berada di root, bukan di bawah `/api/v1`.
  static Uri get healthUri {
    final base = Uri.parse(ApiClient.baseUrl);
    return base.replace(path: '/api', query: null);
  }

  /// Memeriksa status koneksi internet dan API
  Future<ConnectionStatus> checkConnection() async {
    if (_isChecking) return _status;
    _isChecking = true;
    notifyListeners();

    bool hasInternet = false;

    // 1. Cek apakah ada akses internet ke luar
    try {
      final probe = await http
          .get(Uri.parse('https://dns.google/resolve?name=google.com'))
          .timeout(const Duration(seconds: 3));
      hasInternet = probe.statusCode == 200;
    } catch (_) {
      // Jika dns.google gagal, coba fallback probe cepat
      try {
        final probe2 = await http
            .get(Uri.parse('https://www.gstatic.com/generate_204'))
            .timeout(const Duration(seconds: 3));
        hasInternet = probe2.statusCode == 204 || probe2.statusCode == 200;
      } catch (_) {
        hasInternet = false;
      }
    }

    if (!hasInternet) {
      _status = ConnectionStatus.noInternet;
      _lastError = 'Perangkat tidak terhubung ke jaringan internet.';
      _isChecking = false;
      _lastChecked = DateTime.now();
      notifyListeners();
      return _status;
    }

    // 2. Internet ada, sekarang cek apakah REST API kita bisa dihubungi
    try {
      final res = await http
          .get(healthUri, headers: const {'Accept': 'application/json'})
          .timeout(_probeTimeout);

      // /api mengembalikan 200 saat aplikasi dan database siap,
      // 503 saat database tidak tersedia. Keduanya berarti server terjangkau.
      if (res.statusCode == 200) {
        _status = ConnectionStatus.connected;
        _lastError = null;
        await _syncBukuData();
      } else if (res.statusCode >= 500) {
        _status = ConnectionStatus.apiOffline;
        _lastError = _healthMessage(res) ??
            'Server API mengembalikan kode ${res.statusCode}.';
      } else {
        // 404/405: endpoint health belum ada, tapi server merespons.
        _status = ConnectionStatus.connected;
        _lastError = null;
      }
    } catch (e) {
      _status = ConnectionStatus.apiOffline;
      _lastError =
          'Server REST API (${ApiClient.baseUrl}) tidak dapat dijangkau.';
    }

    _isChecking = false;
    _lastChecked = DateTime.now();
    notifyListeners();
    return _status;
  }

  /// Sinkronisasi ringkas data buku ke cache lokal untuk memvalidasi
  /// bahwa database backend benar-benar dapat dibaca oleh aplikasi.
  Future<void> _syncBukuData() async {
    try {
      final data = await ApiClient.getJson('/buku', query: {'per_page': '1'});
      await OfflineCache.saveBooks(data);
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (_) {
      // Sinkronisasi gagal tidak mengubah status koneksi; data lama tetap dipakai.
    }
  }

  String? _healthMessage(http.Response res) {
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is Map<String, dynamic> && body['database'] == 'unavailable') {
        return 'Server API aktif, tetapi database tidak tersedia.';
      }
    } catch (_) {}
    return null;
  }
}
