import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola cache data lokal di SharedPreferences agar aplikasi tetap dapat menampilkan
/// data terakhir saat server REST API tidak aktif / offline.
class OfflineCache {
  OfflineCache._();

  static const String _keyBooks = 'offline_cache_books';
  static const String _keyLoans = 'offline_cache_loans';
  static const String _keyLastSync = 'offline_cache_last_sync';

  /// Menyimpan respons buku terakhir ke cache lokal
  static Future<void> saveBooks(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBooks, jsonEncode(data));
      await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  /// Mengambil data buku dari cache lokal
  static Future<Map<String, dynamic>?> getBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyBooks);
      if (str != null && str.isNotEmpty) {
        return jsonDecode(str) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Menyimpan respons peminjaman terakhir ke cache lokal
  static Future<void> saveLoans(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLoans, jsonEncode(data));
      await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  /// Mengambil data peminjaman dari cache lokal
  static Future<Map<String, dynamic>?> getLoans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLoans);
      if (str != null && str.isNotEmpty) {
        return jsonDecode(str) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Mengambil waktu sinkronisasi terakhir
  static Future<String?> getLastSyncTimeFormatted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLastSync);
      if (str != null) {
        final dt = DateTime.tryParse(str);
        if (dt != null) {
          final now = DateTime.now();
          final diff = now.difference(dt);
          if (diff.inMinutes < 1) return 'Baru saja';
          if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
          if (diff.inHours < 24) return '${diff.inHours} jam lalu';
          return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        }
      }
    } catch (_) {}
    return null;
  }

  /// Hapus seluruh cache offline
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBooks);
      await prefs.remove(_keyLoans);
      await prefs.remove(_keyLastSync);
    } catch (_) {}
  }
}

