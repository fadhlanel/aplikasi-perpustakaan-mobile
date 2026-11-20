import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/api_client.dart';

/// Konfigurasi perpustakaan dari `GET /api/v1/config` yang dikelola admin
/// pada halaman Pengaturan Sistem. Status layanan memengaruhi perilaku
/// aplikasi mobile (badge status & aksi peminjaman).
class ConfigProvider extends ChangeNotifier with WidgetsBindingObserver {
  ConfigProvider() {
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  Timer? _timer;
  static const _pollInterval = Duration(seconds: 3);

  String statusLayanan = 'aktif';
  String namaPerpustakaan = 'PustakaDigital';
  String namaSekolah = 'SMK Negeri 6 Jember';
  String whatsappNomor = '081234567890';
  String whatsappTemplate = 'Halo Pustakawan, saya {nama} (NIS: {nis}) ingin bertanya perihal layanan perpustakaan.';
  int durasiPeminjaman = 3;
  int batasBuku = 3;
  int durasiPerpanjangan = 1;

  bool get layananAktif => statusLayanan == 'aktif';

  String get statusLabel {
    switch (statusLayanan) {
      case 'pemeliharaan':
        return 'Pemeliharaan';
      case 'tutup':
        return 'Perpustakaan Tutup';
      default:
        return 'Perpustakaan Aktif';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load();
      _startPolling();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _timer?.cancel();
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final res = await ApiClient.getJson('/config');
      final data = res['data'] is Map ? res['data'] as Map : res;
      statusLayanan = _text(data['status_layanan'], fallback: 'aktif');
      namaPerpustakaan = _text(data['nama_perpustakaan'], fallback: namaPerpustakaan);
      namaSekolah = _text(data['nama_sekolah'], fallback: namaSekolah);
      whatsappNomor = _text(data['whatsapp_nomor'], fallback: whatsappNomor);
      whatsappTemplate = _text(data['whatsapp_template'], fallback: whatsappTemplate);
      durasiPeminjaman = _int(data['durasi_peminjaman'], fallback: durasiPeminjaman);
      batasBuku = _int(data['batas_buku'], fallback: batasBuku);
      durasiPerpanjangan = _int(data['durasi_perpanjangan'], fallback: durasiPerpanjangan);
    } catch (_) {
      // Koneksi gagal: pertahankan nilai terakhir agar status tidak salah
      // ditampilkan sebagai "Aktif" padahal server sedang tidak dapat dihubungi.
    }
    notifyListeners();
  }

  static String _text(Object? value, {required String fallback}) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  static int _int(Object? value, {required int fallback}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
