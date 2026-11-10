import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/peminjaman.dart';

/// Riwayat peminjaman user tersimpan di device,
/// dicari berdasarkan NIS yang dipakai saat meminjam.
class RiwayatProvider extends ChangeNotifier {
  RiwayatProvider();

  static const _keyNis = 'nis';
  static const _keyNama = 'nama_peminjam';

  List<Peminjaman> riwayat = const <Peminjaman>[];
  bool loading = false;
  String? error;
  String savedNis = '';
  String savedNama = '';

  /// Tampilkan dummy data (diizinkan PDF: "dummy diperbolehkan")
  /// dipakai untuk pratinjau ketika API belum menyiapkan data riwayat.
  void tampilkanDummy() {
    riwayat = <Peminjaman>[
      Peminjaman.dummy(),
    ];
    notifyListeners();
  }

  /// Ambil NIS + nama terakhir kali pinjam dari device.
  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    savedNis = prefs.getString(_keyNis) ?? '';
    savedNama = prefs.getString(_keyNama) ?? '';
    notifyListeners();
  }

  /// Simpan identitas peminjam di device.
  Future<void> simpanIdentitas({
    required String nama,
    required String nis,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNama, nama.trim());
    await prefs.setString(_keyNis, nis.trim());
    savedNama = nama.trim();
    savedNis = nis.trim();
    notifyListeners();
  }

  /// Fetch riwayat peminjaman berdasarkan NIS yang tersimpan.
  Future<void> load({String? nisOverride}) async {
    final nis = (nisOverride ?? savedNis).trim();
    if (nis.isEmpty) {
      riwayat = const <Peminjaman>[];
      error = null;
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.getJson('/peminjaman', query: {
        'search': nis,
        'per_page': '50',
        'page': '1',
      });
      final data = res['data'];
      if (data is List) {
        riwayat = data
            .whereType<Map<String, dynamic>>()
            .map(Peminjaman.fromJson)
            .where((e) => e.nis == nis)
            .toList(growable: false);
      } else {
        riwayat = const <Peminjaman>[];
      }
      loading = false;
    } on ApiException catch (e) {
      riwayat = const <Peminjaman>[];
      error = e.message;
      loading = false;
    } finally {
      notifyListeners();
    }
  }
}
