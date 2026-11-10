import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

enum ConnectionStatus {
  connected,   // Terhubung ke REST API
  apiOffline,  // Terhubung ke internet, namun server API tidak dapat dijangkau
  noInternet,  // Tidak ada koneksi internet sama sekali
}

class NetworkService extends ChangeNotifier {
  NetworkService() {
    checkConnection();
    _startPeriodicCheck();
  }

  /// Interval pengecekan koneksi otomatis ke API.
  static const Duration checkInterval = Duration(seconds: 15);

  Timer? _timer;
  ConnectionStatus _status = ConnectionStatus.connected;
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
    }
  }

  @override
  void dispose() {
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

  /// Memeriksa status koneksi internet dan API
  Future<ConnectionStatus> checkConnection() async {
    if (_isChecking) return _status;
    _isChecking = true;
    notifyListeners();

    bool hasInternet = false;

    // Laravel health endpoint default: /up.
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
      final apiUri = Uri.parse('${ApiClient.baseUrl}/buku?per_page=1');
      final res = await http.get(apiUri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 4));

      if (res.statusCode < 500) {
        _status = ConnectionStatus.connected;
        _lastError = null;
      } else {
        _status = ConnectionStatus.apiOffline;
        _lastError = 'Server API mengembalikan kode ${res.statusCode}.';
      }
    } catch (e) {
      _status = ConnectionStatus.apiOffline;
      _lastError = 'Server REST API (${ApiClient.baseUrl}) tidak dapat dijangkau.';
    }

    _isChecking = false;
    _lastChecked = DateTime.now();
    notifyListeners();
    return _status;
  }
}

